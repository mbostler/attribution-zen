class Attribution::SecurityPerformanceCalculator
  attr_accessor :day
  
  def initialize( opts={} )
    self.day = opts[:day]
  end
  
  def calculate
    @security_days = holdings.map do |cusip, h|
      eop_weight = calc_eop_weight( h )
      performance = calc_performance( h )
      contribution = calc_bop_weight( h ) * (performance-1)      
      
      h.associate_company if h.company_id.blank?
      sd = Attribution::SecurityDay.create!(
        weight: eop_weight, 
        performance: performance,
        contribution: contribution,
        company_id: h.company_id,
        day_id: day.id
      )
      sd
    end
  end
  
  def results
    @security_days.inject( {} ) do |hsh, security_day|
      hsh[security_day.tag] = security_day
      hsh
    end
  end
  
  # note these are USABLE HOLDINGS!
  def holdings
    @holdings ||= day.usable_holdings.inject( {} ) do |s, holding|
      s[holding.tag] = holding
      s
    end
  end
  
  # note these are USABLE HOLDINGS!
  def prev_holdings
    day.prev_day.download unless day.prev_day.completed?
    @prev_holdings = day.usable_prev_holdings.inject( {} ) do |s, holding|
      s[holding.tag] = holding
      s
    end
  end
  
  def calc_eop_weight( h )
    BigDecimal( h.market_value.to_s ) / h.day.total_market_value
  end
  
  def calc_bop_weight( h )
    prev_h = prev_holdings[h.tag]
    num = if !!(prev_h.nil? || prev_h.market_value.nil?)
      day.transactions.where( cusip: h.cusip ).inject( BigDecimal("0.0") ) { |s, x| s += x }
    else
      BigDecimal(prev_h.market_value.to_s)
    end
    denom = day.prev_day.total_market_value
    num / denom
  end

  def calc_performance( h )
    perf = Attribution::PerformanceCalculator.calc holdings: [h], 
                                                   prev_holdings: [prev_holdings[h.tag]],
                                                   transactions: transactions_for_holding( h )
    perf
  end
  
  def transactions_for_holding( holding )
    if holding.company.tag == "cash"
      Attribution::Transaction.where( day_id: holding.day_id )
     else
      Attribution::Transaction.where( day_id: holding.day_id, company_id: holding.company_id )
    end
  end
    
end
