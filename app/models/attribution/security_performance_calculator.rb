class Attribution::SecurityPerformanceCalculator
  attr_accessor :day
  
  def initialize( opts={} )
    self.day = opts[:day]
  end
  
  def calculate
    day.compute_portfolio_day unless day.completed?
    @security_days = holdings.map do |cusip, h|
      eop_weight = calc_eop_weight( h )
      performance = calc_performance( h )
      contribution = calc_bop_weight( h ) * (performance-1)      
      
      h.associate_company if h.company_id.blank?
      sd = day.security_days.create!(
        weight: eop_weight, 
        performance: performance,
        contribution: contribution,
        company_id: h.company_id
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
    day.prev_day.download unless day.prev_day.downloaded?
    @prev_holdings = day.usable_prev_holdings.inject( {} ) do |s, holding|
      s[holding.tag] = holding
      s
    end
  end
  
  def calc_eop_weight( h )
    BigDecimal( h.market_value.to_s ) / h.day.total_market_value
  end
  
  def audit_eop_weight( h )
    puts "holding market value: #{h.market_value}"
    puts "day's total market value: #{h.day.total_market_value}"
    puts "eop weight: #{calc_eop_weight( h )}"
  end
  
  def calc_bop_weight( h )
    prev_h = prev_holdings[h.tag]
    num = if !!(prev_h.nil? || prev_h.market_value.nil?)
      txns = day.transactions.where( cusip: h.cusip )
      txns.inject( BigDecimal("0.0") ) { |s, txn| s += txn.trade_amount }
    else
      BigDecimal(prev_h.market_value.to_s)
    end
    denom = day.prev_day.total_market_value
    num / denom
  end

  def calc_performance( h )
    perf = Attribution::PerformanceCalculator.calc holdings: [h], 
                                                   prev_holdings: [prev_holdings[h.tag]],
                                                   transactions: transactions_for_holding( h ),
                                                   treat_as_cash: h.cash_type?
    perf
  end
  
  def audit_performance( h )
    puts "holding: #{h.inspect}"
    puts "prior holdings: #{prev_holdings[h.tag].inspect}"
    puts "transactions: #{transactions_for_holding( h ).to_a.inspect}"
    puts "cash_type?: #{h.cash_type?.inspect}"
    
    perf = Attribution::PerformanceCalculator.audit holdings: [h],
                                                    prev_holdings: [prev_holdings[h.tag]],
                                                    transactions: transactions_for_holding( h ),
                                                    treat_as_cash: h.cash_type?
    
  end
  
  def transactions_for_holding( holding )
    if holding.company.tag == "cash"
      Attribution::Transaction.where( day_id: holding.day_id )
     # elsif holding.company.tag == "intacc"
     #   Attribution::Transaction.where( day_id: holding.day_id, company_id: holding.company_id )
     else
      Attribution::Transaction.where( day_id: holding.day_id, company_id: holding.company_id )
    end
  end
    
end
