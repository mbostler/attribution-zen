class Attribution::Report
  attr_accessor :portfolio, :start_date, :end_date, :securities, 
                :cumulative_security_performances, :cumulative_portfolio_performance, :cumulative_security_contributions,
                :companies
  
  def initialize( opts={} )
    @portfolio = opts[:portfolio]
    @start_date = opts[:start_date]
    @end_date = opts[:end_date]
    @companies = Hash.new { |h, k| h[k] = {} }
  end
  
  def calculate
    ensure_days_are_completely_downloaded
    ensure_security_days_are_completely_calculated
    calculate_cumulative_security_performances
    calculate_cumulative_portfolio_performance
    calculate_cumulative_security_contributions
    @results = { :security => security_stats }
  end
  
  def ensure_security_days_are_completely_calculated
    days.sort_by(&:date).each do |d|
      if d.security_days.empty?
        # ActiveRecord::Base.transaction do
          calculator = Attribution::SecurityPerformanceCalculator.new :day => d
          calculator.calculate
        # end
      end
    end
  end
  
  def calculate_cumulative_security_performances
    self.securities = Hash.new { |h, k| h[k] = [] }
    days.sort_by(&:date).each do |d|
      d.security_days.each do |sd|
        securities[sd.company_id] << sd
      end
    end
    
    @cumulative_security_performances = {}
    securities.each do |company_id, security_days|
      company = Attribution::Company.find( company_id )
      puts "#{company.tag.ljust(10)} | #{security_days.inspect}"
      cumulative_perf = geo_link security_days.map(&:performance)
      
      @companies[company][:performance] = cumulative_perf
      @cumulative_security_performances[company.tag] = cumulative_perf
    end
    @cumulative_security_performances
  end
  
  def calculate_cumulative_security_contributions
    @cumulative_security_contributions = {}
    security_days_by_company = Hash.new { |h, k| h[k] = [] }
    contribution_days_by_company = Hash.new { |h, k| h[k] = [] }
    
    days.sort_by(&:date).each do |d|
      d.security_days.each do |sd|
        security_days_by_company[sd.company_id] << sd
      end
    end
    
    security_days_by_company.each do |company_id, security_days|
      company = Attribution::Company.find( company_id )
      contrib = security_contribution( security_days )
      @companies[company][:contribution] = contrib
      @cumulative_security_contributions[company.tag] = contrib
    end
  end
  
  
  def calculate_cumulative_portfolio_performance
    range = (@start_date..@end_date).select(&:trading_day?)
    daily_performances = range.to_a.map do |d| 
      puts "PORT PERF: #{d} | #{@portfolio.day( d ).portfolio_day}"
      @portfolio.day( d ).portfolio_day.performance
    end
    @cumulative_portfolio_performance = geo_link daily_performances
  end
  
  def days
    @portfolio.days.where( :date => @start_date..@end_date )
  end
  
  def ensure_days_are_completely_downloaded
    trading_days = (@start_date.prev_trading_day..@end_date).select(&:trading_day?)
    trading_days.each do |date|
      ensure_day_is_downloaded( date )
    end
    
    trading_days[1..-1].each do |date|
      ensure_day_is_computed( date )
    end
  end
  
  def ensure_day_is_downloaded( date )
    day = @portfolio.days.where(:date => date).first_or_create
    raise "no portfolio day for #{date}" if day.nil?
    day.download unless day.downloaded?
  end
  
  def ensure_day_is_computed( date )
    day = @portfolio.days.where(:date => date).first
    raise "no portfolio day for #{date}" if day.nil?
    day.compute_portfolio_day unless day.completed?
  end
  
  def security_stats
    hsh = Hash.new { |h, k| h[k] = {} }
    securities.inject(hsh) do |stats, cusip_and_days|
      cusip = cusip_and_days.first
      sec_days = cusip_and_days.last
      
      stats[cusip][:performance]  = security_performance( sec_days )
      stats[cusip][:contribution] = security_contribution( sec_days )
      stats
    end
  end
  
  def security_return_stats
    hsh = Hash.new { |h, k| h[k] = {} }
    securities.inject(hsh) do |stats, cusip_and_days|
      cusip = cusip_and_days.first
      ticker = Attribution::Holding.where( :cusip => cusip ).first.ticker
      sec_days = cusip_and_days.last
      
      stats[ticker][:performance]  = security_performance( sec_days )
      stats
    end    
  end
  
  def portfolio_days
    days.inject({}) do |hsh, day|
      hsh[day.date] = day.portfolio_day
      hsh
    end
  end
  
  def days
    @portfolio.days.where( :date => [@start_date..@end_date] )
  end
  
  def pv_multiplier( security_day )
    future_days = (@start_date..@end_date).select(&:trading_day?).to_a.select { |d| d > security_day.date }
    future_performance_days = future_days.map{ |d| portfolio_days[d].performance }
    geo_link future_performance_days
  end
  
  def security_performance( security_days )
    geo_link( security_days.map { |sd| sd.performance } )
  end
  
  def security_contribution( security_days )
    sum( security_days.map { |sd| contribution_addend( sd ) } )
  end
  
  def contribution_addend( security_day )
    (security_day.contribution || 0) * pv_multiplier( security_day )
  end
  
  def security_results
    @results[:security]
  end
  
  def audit(ticker=nil)
    if ticker.nil?
      audit_portfolio
    else
      audit_security( ticker )
    end
  end
  
  def audit_security( tag )
    tag_holdings = days.map do |d| 
      d.holdings.find { |h| h.company.tag.upcase == tag.upcase }
    end.compact
    
    tag_holdings.each do |h|
      h.audit
    end
  end
  
  def audit_portfolio
    cumulative_security_performances.each do |company_tag, perf|
      puts "#{company_tag.ljust(10)} | #{percentagize( perf ).round(4)}"
    end
  end
  
  def print_results
    tickers = @results[:security].keys.inject( {} ) do |hsh, cusip|
      ticker = Attribution::Holding.where( :cusip => cusip ).first.ticker
      hsh[cusip] = ticker
      hsh
    end
    
    puts "ATTRIBUTION REPORT FOR #{portfolio.name}"
    puts "Start date: #{start_date}"
    puts "End date: #{end_date}"
    puts "TOTAL RETURN: #{sprintf('%.5f', percentagize( cumulative_portfolio_return ))}"
    puts "======================================"
    puts "Ticker |   Return | Contribution"
    @results[:security].each do |cusip, stats|
      ticker = tickers[cusip]
      perf = stats[:performance]
      contrib = stats[:contribution]
      puts "#{(ticker || "(na)").ljust(6)} | #{sprintf( '%.5f', percentagize(perf)).rjust(8)} | #{sprintf( '%.5f', contrib*100).rjust(8)}"
    end

    puts "value of cumulative_portfolio_return is: #{'%.5f' % percentagize(cumulative_portfolio_return)}"
    summed_contribs = @results[:security].values.inject( BigDecimal("0.0") ) { |s, x| s += x[:contribution] }
    puts "value of summed_contribs is: #{'%.5f' % summed_contribs}"
  end
  
  # def cumulative_portfolio_return
  #   range = (@start_date..@end_date)
  #   geo_link range.to_a.map { |d| @portfolio.days.where( :date => d ).first.portfolio_day.performance }
  # end
  #
  # NOTE: this assumes it takes depercentagized numbers!
  def geo_link( nums )
    nums.compact.inject( BigDecimal("1.0") ) { |product, factor| product *= factor }
  end

  # "normalize" with respect to what is right mathematically
  # eg.,  depercentagize("5") => 1.05
  def depercentagize( num )
    BigDecimal(num.to_s) / 100 + 1
  end
  
  # 1.05 => 5
  def percentagize( num )
    (BigDecimal(num.to_s) - 1.0)*100
  end
  
  def sum( nums )
    nums.inject( BigDecimal("0.0") ) { |sum, addend| sum += addend }
  end
  
  def lookup_security_days( tag )
    c = Attribution::Company.find_by_tag( tag )
    return nil unless c
    c.security_days.where( :day_id => days.map(&:id) )
  end
end
