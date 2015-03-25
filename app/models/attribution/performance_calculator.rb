class Attribution::PerformanceCalculator
  attr_accessor :holdings, :prev_holdings, :transactions
  
  def self.calc( opts )
    new( opts ).calculate
  end
  
  def self.audit( opts )
    new( opts ).audit    
  end
  
  def initialize( opts={} )
    @holdings = opts[:holdings]
    @prev_holdings = opts[:prev_holdings]
    @transactions = opts[:transactions]
    @treat_as_cash = opts[:treat_as_cash]
    @treat_as_total = opts[:treat_as_total]
    @treat_as_intacc = opts[:treat_as_intacc]
  end

  def calculate
    num / (denom || 1)
  end
  
  def txns
    t = sales + los - purchases - lis - ins + wds
    t *= -1 if @treat_as_cash
    t -= ins if @treat_as_intacc
    t
  end
  
  def denom
    bmv.zero? ? (purchases + lis + ins) : bmv
  end
  
  def num
    if bmv.zero?
      BigDecimal(emv.to_s)
    else
      BigDecimal(emv.to_s) + txns
    end
  end
  
  def audit
    puts "value of @treat_as_cash is: #{@treat_as_cash.inspect}"
    puts "value of @treat_as_total is: #{@treat_as_total.inspect}"
    puts "value of @treat_as_intacc is: #{@treat_as_intacc.inspect}"
    [:sales, :purchases, :lis, :ins, :wds, :los, :emv, :bmv, :txns, :num, :denom, :calculate].each do |stat|
      puts "\t#{stat.to_s}: #{send(stat)}"
    end
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
  
  def lis
    @transactions.lis.inject( BigDecimal( "0.0") ) { |s, txn| s += txn.trade_amount }    
  end
  
  def ins
    @transactions.ins.inject( BigDecimal( "0.0") ) { |s, txn| s += txn.trade_amount }    
  end
  
  def wds
    @transactions.wds.inject( BigDecimal( "0.0") ) { |s, txn| s += txn.trade_amount }    
  end
  
  def los
    @transactions.lis.inject( BigDecimal( "0.0") ) { |s, txn| s += txn.trade_amount }    
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
