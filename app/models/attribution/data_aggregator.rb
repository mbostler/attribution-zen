class Attribution::DataAggregator
  attr_accessor :portfolio, :date
  
  TIME_FRAMES = {
    :today => "Today",
    :wtd => "WTD",
    :mtd => "MTD",
    :ytd => "YTD",
    :ltm => "LTM",
    :since_inception => "Since Inception"
  }
  
  def initialize( opts={} )
    @date = opts[:date]
    @portfolio = opts[:portfolio]
    @company_lookups = Hash.new { |h, k| h[k] = {} }
  end
  
  def create_reports
    TIME_FRAMES.each do |meth_prefix, title|
      start_date = calc_start_date( meth_prefix )
      puts "value of start_date is: #{start_date.inspect}"
      report = Attribution::Report.new :portfolio => @portfolio, :start_date => start_date, :end_date => @date
      report.calculate
      report.companies.each do |company, report_stats|
        @company_lookups[company.id].merge! company_stats_from_report( company, report_stats, meth_prefix )
      end
    end
  end
  
  def companies
    @company_lookups.values
  end
  
  def company_stats_from_report( company, report_stats, meth_prefix )
    {
      symbol: company.tag,
      cusip: company.cusip,
      "#{meth_prefix.to_s}_performance".to_sym => percentagize(report_stats[:performance]-1),
      "#{meth_prefix.to_s}_contribution".to_sym => percentagize(report_stats[:contribution])
    }
  end
  
  def calc_start_date( prefix )
    puts "value of prefix is: #{prefix.inspect}"
    send "#{prefix.to_s}_start_date"
  end
  
  def today_start_date
    @date
  end
  
  def wtd_start_date
    d = @date 
    d -= 1 until d.wday == 0
    d.next_trading_day
  end
  
  def mtd_start_date
    Date.civil( @date.year, @date.month, 1 )
  end

  def ytd_start_date
    # TODO: fix
    Date.civil( @date.year, 1, 1 )
    # Date.civil( @date.year, @date.month, 1 )
  end
  
  def ltm_start_date
    # TODO: implement
    Date.civil( @date.year, @date.month, 1 )    
  end
  
  def since_inception_start_date
    # TODO: implement
    Date.civil( @date.year, @date.month, 1 )    
  end
  
  def percentagize(num)
    return '' if num.blank?
    '%0.3f' % (num*100)
  end
end
