class Attribution::SecurityPerformanceCalculator
  attr_accessor :day
  
  def calculate
    @security_days = holdings.map do |cusip, h|
      
      eop_weight = calc_eop_weight( h )
      performance = calc_performance( h )
      contribution = calc_bop_weight( h ) * (performance-1)
      
      h.associate_company
      sd = Attribution::SecurityDay.create!(
        weight: eop_weight, 
        performance: performance,
        contribution: contribution,
        cusip: h.cusip
      )
    end    
  end
  
  def results
    @security_days.inject( {} ) do |hsh, security_day|
      hsh[security_day.ticker] = security_day
      hsh
    end
  end
  
  def holdings
    @holdings ||= day.holdings.inject( {} ) do |s, holding|
      s[holding.cusip] = holding
      s
    end
  end
  
  def prev_holdings
    @prev_holdings = day.prev_holdings.inject( {} ) do |s, holding|
      s[holding.cusip] = holding
      s
    end
  end
  
  def calc_eop_weight( h )
    BigDecimal( h.market_value.to_s ) / h.day.total_market_value
  end
  
  def calc_bop_weight( h )
    prev_h = prev_holdings[h.cusip]
    BigDecimal(prev_h.market_value.to_s) / prev_h.day.total_market_value
  end

  def calc_performance( h )
    BigDecimal( h.market_value.to_s ) / prev_holdings[h.cusip].market_value
  end
  
end
