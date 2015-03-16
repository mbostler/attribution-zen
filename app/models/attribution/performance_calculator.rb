class Attribution::PerformanceCalculator
  attr_accessor :holdings, :prev_holdings, :transactions
  
  def self.calc( opts )
    new( opts ).calculate
  end
  
  def initialize( opts={} )
    @holdings = opts[:holdings]
    @prev_holdings = opts[:prev_holdings]
    @transactions = opts[:transactions]
  end

  def calculate
    sleep(0.5)
    BigDecimal(emv.to_s) / (bmv || 1)
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
