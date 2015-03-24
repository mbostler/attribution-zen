class Attribution::PerformanceCalculator
  attr_accessor :holdings, :prev_holdings, :transactions
  
  def self.calc( opts )
    new( opts ).calculate
  end
  
  def initialize( opts={} )
    @holdings = opts[:holdings]
    @prev_holdings = opts[:prev_holdings]
    @transactions = opts[:transactions]
    @treat_as_cash = opts[:treat_as_cash]
    @treat_as_total = opts[:treat_as_total]
  end

  def calculate
    txns = sales - purchases
    txns *= -1 if @treat_as_cash
    num = BigDecimal(emv.to_s) + txns
    denom = bmv
    num / (denom || 1)
  end
  
  def cash_holding?
    @holdings.first.company.tag == "cash"
  end
  
  def sales
    return 0 if @treat_as_total
    @transactions.sales.inject( BigDecimal( "0.0") ) { |s, txn| s += txn.trade_amount }
  end
  
  def purchases
    return 0 if @treat_as_total
    @transactions.purchases.inject( BigDecimal( "0.0") ) { |s, txn| s += txn.trade_amount }
  end
  
  def emv
    naive_emv = holdings.inject( BigDecimal( "0.0" ) ) { |s, h| s += h.market_value }
    naive_emv || 1
  end
  
  def bmv
    prev_holdings.inject( BigDecimal( "0.0" ) ) do |s, h|
      addend = ((h and h.market_value) or 0)
      s += addend
    end
  end
  
end
