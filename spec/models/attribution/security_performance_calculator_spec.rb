require 'rails_helper'

RSpec.describe Attribution::SecurityPerformanceCalculator, :type => :model do
  describe 'calculating perfomrance for securities'
    it 'correctly calculates when zero transactions' do
      calculator = Attribution::SecurityPerformanceCalculator.new
      
      d0 = Date.civil( 2015, 2, 18 )
      d1 = d0 + 1
      
      day1 = Attribution::Day.create! :date => d1
      day0 = Attribution::Day.create! :date => d0
      
      holdings1 = [
        { market_value:  40, cusip: "1", ticker: "A", day_id: day1.id },
        { market_value:  50, cusip: "2", ticker: "B", day_id: day1.id },
        { market_value: 110, cusip: "3", ticker: "C", day_id: day1.id }
      ]

      holdings0 = [
        { market_value:  25, cusip: "1", ticker: "A", day_id: day0.id },
        { market_value:  50, cusip: "2", ticker: "B", day_id: day0.id },
        { market_value: 125, cusip: "3", ticker: "C", day_id: day0.id }
      ]
      
      allow( day1 ).to receive( :holdings ).and_return( attribs_to_holdings( holdings1 ) )
      allow( day1 ).to receive( :transactions ).and_return( [] )
      
      allow( day0 ).to receive( :prev_holdings ).and_return( attribs_to_holdings( holdings0 ) )
      allow( day0 ).to receive( :prev_transactions ).and_return( [] )
      
      allow_any_instance_of( Attribution::Day ).to receive( :ensure_download ).and_return( true )
      
      calculator.day = day1
      calculator.calculate
      results = calculator.results

      expect( results["A"].class ).to eq( Attribution::SecurityDay )
      expect( results["A"].weight ).to eq( 0.2 )
      expect( results["A"].performance ).to eq( 1.6 )
      expect( results["A"].contribution ).to eq( 0.075 )
      
      expect( results["B"].class ).to eq( Attribution::SecurityDay )
      expect( results["B"].weight ).to eq( 0.25 )
      expect( results["B"].performance ).to eq( 1.0 )
      expect( results["B"].contribution ).to eq( 0.0 )
      
      expect( results["C"].class ).to eq( Attribution::SecurityDay )
      expect( results["C"].weight ).to eq( 0.55 )
      expect( results["C"].performance ).to eq( 0.88 )
      expect( results["C"].contribution ).to eq( -0.075 )
    end
  
end

def attribs_to_holdings( holdings_attribs )
  holdings_attribs.map do |attribs|
    Attribution::Holding.create! attribs
  end
end