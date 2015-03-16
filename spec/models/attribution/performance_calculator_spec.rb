require 'rails_helper'

RSpec.describe Attribution::PerformanceCalculator, :type => :model do
  it 'should calculate performance the right way' do
    todays_holdings = [
      { market_value:  40, cusip: "1", ticker: "A" }
    ]
    
    yesterdays_holdings = [
      { market_value:  50, cusip: "1", ticker: "A" }
    ]
    
    calculator = Attribution::PerformanceCalculator.new( 
      :holdings => attribs_to_holdings(todays_holdings),
      :prev_holdings => attribs_to_holdings(yesterdays_holdings),
      :transactions => [])
      
    result = calculator.calculate
    
    expect( result ).to eq( 0.8 )
  end
end

def attribs_to_holdings( holdings_attribs )
  holdings_attribs.map do |attribs|
    Attribution::Holding.create! attribs
  end
end