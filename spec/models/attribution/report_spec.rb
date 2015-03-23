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
  
  end
  
  describe 'when calculating reports for ginkgo on 10/2/2014' do
    before( :each ) do
      @portfolio = Attribution::Portfolio.where( name: "ginkgo" ).first_or_create
      
      date = Date.civil( 2014, 10, 2 )
      
      expect_axys_reports "ginkgo", date
      expect_axys_reports "ginkgo", date-1
      
      @rep = Attribution::Report.new portfolio: @portfolio, start_date: date, end_date: date
    end
    
    it 'should correctly calculate for the transactions', focus: true do
      @rep.calculate

      d = @rep.days.last
      d.print_holdings d.holdings
    
      @rep.audit

      expect( '%0.8f' % @rep.cumulative_security_performances["WCG"] ).to eq("1.00454545")
      expect( '%0.8f' % @rep.cumulative_security_contributions["WCG"] ).to eq("0.00012274")
      expect( '%0.8f' % @rep.cumulative_security_performances["FUL"] ).to eq("1.00132784")
      expect( '%0.8f' % @rep.cumulative_security_contributions["FUL"] ).to eq("0.00001358")
      expect( '%0.8f' % @rep.cumulative_security_performances["DGI"] ).to eq("1.00225210")
      expect( '%0.8f' % @rep.cumulative_security_contributions["DGI"] ).to eq("0.00007640")
      expect( '%0.8f' % @rep.cumulative_security_performances["MSCC"] ).to eq("1.00506940")
      expect( '%0.8f' % @rep.cumulative_security_contributions["MSCC"] ).to eq("0.00011533")
      expect( '%0.8f' % @rep.cumulative_security_performances["divacc"] ).to eq("1.00000000")
      expect( '%0.8f' % @rep.cumulative_security_performances["cash"] ).to eq("1.00000000")
      expect( '%0.8f' % @rep.cumulative_portfolio_performance ).to eq("1.01014804")
    end

  end
    
  describe 'when calculating reports for ginkgo on 10/4/2013' do
    before( :each ) do
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
    end
    
    it 'should only have one security day for intacc' do
      puts "*** ENSURING"
      @rep.ensure_days_are_completely_downloaded
      @rep.ensure_security_days_are_completely_calculated
      puts "*** ENSURING COMPLETE"
      
      acctfeepay_holding_codes = Attribution::HoldingCode.where( :name => "intacc" ).all
      expect( acctfeepay_holding_codes.size ).to eq( 1 )
      
      hc = acctfeepay_holding_codes.first
      
      companies = Attribution::Company.where( code_id: hc.id ).all
      expect( companies.size ).to eq( 1 )
      sds = Attribution::SecurityDay.all
      # sds.each do |sd|
      #   puts "#{sd.tag.ljust(15)} - #{sd.inspect}"
      # end
      c = companies.first
      expect( c.security_days.size ).to eq( 1 )
    end

    it 'should properly calculate cumulative performances ' do
      @rep.calculate

      d = @rep.days.last
      d.print_holdings d.holdings
    
      @rep.audit

      expect( '%0.8f' % @rep.cumulative_security_performances["TFM"] ).to eq("1.03708333")
      expect( '%0.8f' % @rep.cumulative_security_performances["SPF"] ).to eq("0.97977244")
      expect( '%0.8f' % @rep.cumulative_security_performances["cash"] ).to eq("1.00000000")
      expect( '%0.8f' % @rep.cumulative_security_performances["divacc"] ).to eq("1.00000000")
      expect( '%0.8f' % @rep.cumulative_security_performances["SPF"] ).to eq("0.97977244")
      expect( '%0.8f' % @rep.cumulative_security_contributions["SPF"] ).to eq("-0.00044972")
      expect( '%0.8f' % @rep.cumulative_portfolio_performance ).to eq("1.00662278")
    end
    
  end
end

def attribs_to_holdings( holdings_attribs )
  holdings_attribs.map do |attribs|
    Attribution::Holding.create! attribs
  end
end

def expect_axys_reports( portfolio_name, date )
  txns_file = File.join( Rails.root, "spec/data/ginkgo_transactions_#{date.strftime('%Y_%m_%-d')}.yaml" )
  raise "couldn't find transactions file at #{txns_file}" unless File.exists?(txns_file)
  txns = YAML.load File.read(  txns_file )
  expect( Axys::TransactionsWithSecuritiesReport ).to receive( :run! ).with( portfolio_name: portfolio_name, start: date, end: date ).and_return( txns )

  holdings_file = File.join( Rails.root, "spec/data/ginkgo_holdings_#{date.strftime('%Y_%m_%-d')}.yaml")
  raise "couldn't find holdings file at #{holdings_file}" unless File.exists?(holdings_file)
  attribs = YAML.load File.read( holdings_file )
  expect( Axys::AppraisalWithTickerAndCusipReport ).to receive( :run! ).with( portfolio_name: portfolio_name, start: date).and_return( attribs )
end