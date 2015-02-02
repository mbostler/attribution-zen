class Attribution::PortfolioReturns
  attr_accessor :returns_set
  
  def initialize
    @returns_set = []
  end
  
  def [](idx)
    @returns_set[idx]
  end
  
  def []=(idx, num)
    @returns_set[idx] = BigDecimal( num.to_s )
  end
  
  def total
    geo_link @returns_set
  end
  
  def geo_link( numbers )
    numbers.inject( 1.0 ) { |result, num| result *= num }
  end
    
end