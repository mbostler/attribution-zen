require 'rails_helper'

RSpec.describe Attribution::SecurityPerformanceCalculator, :type => :model do
  it 'should assign day on initialization' do
    d = Date.civil( 2015, 2, 19 )
    day = Attribution::Day.new :date => d
    calculator = Attribution::SecurityPerformanceCalculator.new :day => day
    expect( calculator.day.date ).to eq( d )
  end
  
  describe 'calculating perfomrance for securities' do
    it 'correctly calculates when zero transactions' do
      calculator = Attribution::SecurityPerformanceCalculator.new
      
      d0 = Date.civil( 2015, 2, 18 )
      d1 = d0 + 1
      
      day1 = Attribution::Day.create! :date => d1
      day0 = Attribution::Day.create! :date => d0
      
      attribs1 = [
        { market_value:  40, cusip: "1", ticker: "A", day_id: day1.id },
        { market_value:  50, cusip: "2", ticker: "B", day_id: day1.id },
        { market_value: 110, cusip: "3", ticker: "C", day_id: day1.id }
      ]

      attribs0 = [
        { market_value:  25, cusip: "1", ticker: "A", day_id: day0.id },
        { market_value:  50, cusip: "2", ticker: "B", day_id: day0.id },
        { market_value: 125, cusip: "3", ticker: "C", day_id: day0.id }
      ]
      
      holdings1 = attribs_to_holdings( attribs1 )
      holdings0 = attribs_to_holdings( attribs0 )
      
      
      allow( day1 ).to receive( :holdings ).and_return( holdings1 )
      allow( day1 ).to receive( :transactions ).and_return( [] )
      
      allow( day0 ).to receive( :prev_holdings ).and_return( holdings0 )
      allow( day0 ).to receive( :prev_transactions ).and_return( [] )
      
      allow_any_instance_of( Attribution::Day ).to receive( :ensure_download ).and_return( true )
      
      calculator.day = day1
      cusip_mapped_holdings0 = holdings0.inject({}) do |hsh, holding|
        hsh[holding.cusip] = holding
        hsh
      end
      allow( calculator ).to receive( :prev_holdings ).and_return( cusip_mapped_holdings0 )
      calculator.calculate
      results = calculator.results
      
      expect( calculator.day.prev_day.total_market_value ).to eq( 200 )

      expect( results.values.first.tag ).to eq( "A" )
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
    
    it 'should create security_days that are actually linked to the day' do
      calculator = Attribution::SecurityPerformanceCalculator.new

      d0 = Date.civil( 2015, 2, 18 )
      d1 = d0 + 1

      day1 = Attribution::Day.create! :date => d1
      day0 = Attribution::Day.create! :date => d0

      attribs1 = [
        { market_value:  40, cusip: "1", ticker: "A", day_id: day1.id },
        { market_value:  50, cusip: "2", ticker: "B", day_id: day1.id },
        { market_value: 110, cusip: "3", ticker: "C", day_id: day1.id }
      ]

      attribs0 = [
        { market_value:  25, cusip: "1", ticker: "A", day_id: day0.id },
        { market_value:  50, cusip: "2", ticker: "B", day_id: day0.id },
        { market_value: 125, cusip: "3", ticker: "C", day_id: day0.id }
      ]
      
      holdings1 = attribs_to_holdings( attribs1 )
      holdings0 = attribs_to_holdings( attribs0 )

      allow( day1 ).to receive( :holdings ).and_return( holdings1 )
      allow( day1 ).to receive( :transactions ).and_return( [] )

      allow( day0 ).to receive( :prev_holdings ).and_return( holdings0 )
      allow( day0 ).to receive( :prev_transactions ).and_return( [] )

      allow_any_instance_of( Attribution::Day ).to receive( :ensure_download ).and_return( true )

      calculator.day = day1
      cusip_mapped_holdings0 = holdings0.inject({}) do |hsh, holding|
        hsh[holding.cusip] = holding
        hsh
      end
      allow( calculator ).to receive( :prev_holdings ).and_return( cusip_mapped_holdings0 )
      sec_days = calculator.calculate

      expect( sec_days.size ).to eq( 3 )
      expect( sec_days.first.day_id ).to eq( day1.id )
    end
    
    it 'correctly calcs divacc performance on 10-3-2014' do
      @portfolio = Attribution::Portfolio.where( name: "ginkgo" ).first_or_create
    
      date = Date.civil 2013, 10, 3
      txns = YAML.load File.read( File.join( Rails.root, "spec/data/ginkgo_transactions_2013_10_3.yaml"))
      expect( Axys::TransactionsWithSecuritiesReport ).to receive( :run! ).with( portfolio_name: "ginkgo", start: date, end: date ).and_return( txns )

      date = Date.civil 2013, 10, 4
      txns = YAML.load File.read( File.join( Rails.root, "spec/data/ginkgo_transactions_2013_10_4.yaml"))
      expect( Axys::TransactionsWithSecuritiesReport ).to receive( :run! ).with( portfolio_name: "ginkgo", start: date, end: date ).and_return( txns )

      date = Date.civil 2013, 10, 3
      attribs = YAML.load File.read( File.join( Rails.root, "spec/data/ginkgo_holdings_2013_10_3.yaml"))
      expect( Axys::AppraisalWithTickerAndCusipReport ).to receive( :run! ).with( portfolio_name: "ginkgo", start: date).and_return( attribs )

      date = Date.civil 2013, 10, 4
      attribs = YAML.load File.read( File.join( Rails.root, "spec/data/ginkgo_holdings_2013_10_4.yaml"))
      expect( Axys::AppraisalWithTickerAndCusipReport ).to receive( :run! ).with( portfolio_name: "ginkgo", start: date).and_return( attribs )

      @rep = Attribution::Report.new portfolio: @portfolio, start_date: date, end_date: date
      
      @rep.ensure_days_are_completely_downloaded
      @rep.ensure_security_days_are_completely_calculated
      
      day = @rep.lookup_security_days( "divacc" ).last
      expect( day.performance ).to eq( 1.0 )
    end
    
      
  end
  
end

def attribs_to_holdings( holdings_attribs )
  holdings_attribs.map do |attribs|
    Attribution::Holding.create! attribs
  end
end