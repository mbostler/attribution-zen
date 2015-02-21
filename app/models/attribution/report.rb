class Attribution::Report
  attr_accessor :portfolio, :start_date, :end_date, :securities
  
  def initialize( opts={} )
    @portfolio = opts[:portfolio]
    @start_date = opts[:start_date]
    @end_date = opts[:end_date]
  end
  
  def calculate
    self.securities = Hash.new { |h, k| h[k] = [] }
    ensure_days_are_completely_downloaded
    days.sort_by(&:date).each do |d|
      d.security_days.each do |sd|
        securities[sd.cusip] << sd
      end
    end
    @results = { :security => security_stats }
  end
  
  def days
    @portfolio.days
  end
  
  def ensure_days_are_completely_downloaded
    days.each do |day|
      day.download unless day.completed?
    end
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
      sec_days = cusip_and_days.last
      
      stats[cusip][:performance]  = security_performance( sec_days )
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
    future_days = (@start_date..@end_date).to_a.select { |d| d > security_day.date }
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
    security_day.contribution * pv_multiplier( security_day )
  end
  
  def security_results
    @results[:security]
  end
  
  # NOTE: this assumes it takes depercentagized numbers!
  def geo_link( nums )
    nums.inject( BigDecimal("1.0") ) { |product, factor| product *= factor }
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
end
