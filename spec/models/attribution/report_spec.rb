require 'rails_helper'

RSpec.describe Attribution::Report, :type => :model do
  describe 'when calculating reports' do
    before(:each) { @date = Date.civil(2015, 2, 4) }
    
    let(:report) do
      @date = Date.civil(2015, 2, 4)
      report = Attribution::Report.new :start_date => @date - 7, :end_date => @date + 2
    end

    it 'should properly geo link' do
      report = Attribution::Report.new
      res = report.geo_link [1.0, 0.75, 1.40, 1.80]
      expect( res ).to eq(1.89)
    end
    
    it 'should properly depercentagize a number' do
      report = Attribution::Report.new
      expect( report.depercentagize(50) ).to eq(1.5)
      expect( report.depercentagize(-20) ).to eq(0.8)
    end
    
    it 'should properly percentagize a number' do
      report = Attribution::Report.new
      expect( report.percentagize(1.5) ).to eq(50)
      expect( report.percentagize(0.8) ).to eq(-20)
    end
    
    it 'should properly sum' do
      ary = [5, 6, 7.5]
      expect( report.sum( ary ) ).to eq( 18.5 )
    end
    
    it 'should calculate security stats performance correctly' do
      a1 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.05 )
      a2 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.02 )

      allow(report).to receive(:securities) { 
        { "A" => [a1, a2] }
      }

      results = {"A" => {:performance => 1.071}}
      expect(report.security_return_stats).to eq(results)
    end

    it 'should calculate security stats contribution correctly' do
      d0 = report.end_date - 1
      d1 = report.end_date
      
      a1 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.05, :contribution => 0.025 )
      allow( a1 ).to receive(:date) { d0 }
      a2 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.02, :contribution => 0.01 )
      allow( a2 ).to receive(:date) { d1 }

      b1 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 0.96, :contribution => -0.02 )
      allow( b1 ).to receive(:date) { d0 }
      b2 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.12, :contribution => 0.06 )
      allow( b2 ).to receive(:date) { d1 }
      
      portfolio_days = {
        d0 => Attribution::PortfolioDay.new(:performance => 0.99),
        d1 => Attribution::PortfolioDay.new(:performance => 1.07),
      }
      allow( report ).to receive(:portfolio_days) { portfolio_days }
      allow(report).to receive(:securities) { 
        { 
          "A" => [a1, a2],
          "B" => [b1, b2]
        }
      }

      results = {
        "A" => {:performance => 1.071, :contribution => 0.03675 },
        "B" => {:performance => 1.0752, :contribution => 0.0386 }
      }
      
      expect( report.security_stats["A"][:performance] ).to eq( 1.071 )
      expect( report.security_stats["B"][:performance] ).to eq( 1.0752 )
      expect( report.security_stats["A"][:contribution] ).to eq( 0.03675 )
      expect( report.security_stats["B"][:contribution] ).to eq( 0.0386 )
    end
    
    it 'should properly incorporate a pv multiplier' do
      a1 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.05, :contribution => 0.025 )
      allow(a1).to receive(:date).and_return( @date )
      portfolio_days = {
        @date+1 => Attribution::PortfolioDay.new(:performance => 1.02),
        @date+2 => Attribution::PortfolioDay.new(:performance => 1.015)
      }
      allow( report ).to receive(:portfolio_days).and_return( portfolio_days )
      expect( report.pv_multiplier( a1 ) ).to eq( 1.0353 )
    end
    
    it 'should check to see if it needs to download transactions before calculating' do
      date = Date.civil(2015, 2, 19)
      portfolio_name = "bodhi"
      portfolio = Attribution::Portfolio.where( name: portfolio_name ).first_or_create
      report = Attribution::Report.new portfolio: portfolio,
                                      start_date: date,
                                        end_date: date
      expect( report ).to receive(:ensure_days_are_completely_downloaded)
      report.calculate
    end
    
  end
end
