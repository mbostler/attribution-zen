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
    
    # it 'should calculate security stats contribution correctly' do
    #   d0 = report.end_date - 1
    #   d1 = report.end_date
    #
    #   a1 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.05, :contribution => 0.025 )
    #   allow( a1 ).to receive(:date) { d0 }
    #   a2 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.02, :contribution => 0.01 )
    #   allow( a2 ).to receive(:date) { d1 }
    #
    #   b1 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 0.96, :contribution => -0.02 )
    #   allow( b1 ).to receive(:date) { d0 }
    #   b2 = Attribution::SecurityDay.new( :weight => 0.5, :performance => 1.12, :contribution => 0.06 )
    #   allow( b2 ).to receive(:date) { d1 }
    #
    #   portfolio_days = {
    #     d0 => Attribution::PortfolioDay.new(:performance => 0.99),
    #     d1 => Attribution::PortfolioDay.new(:performance => 1.07),
    #   }
    #   allow( report ).to receive(:portfolio_days) { portfolio_days }
    #   allow(report).to receive(:securities) {
    #     {
    #       "A" => [a1, a2],
    #       "B" => [b1, b2]
    #     }
    #   }
    #
    #   results = {
    #     "A" => {:performance => 1.071, :contribution => 0.03675 },
    #     "B" => {:performance => 1.0752, :contribution => 0.0386 }
    #   }
    #
    #   expect( report.security_stats["A"][:performance] ).to eq( 1.071 )
    #   expect( report.security_stats["B"][:performance] ).to eq( 1.0752 )
    #   expect( report.security_stats["A"][:contribution] ).to eq( 0.03675 )
    #   expect( report.security_stats["B"][:contribution] ).to eq( 0.0386 )
    # end
    
    # it 'should not create more security days when calculating when the days are complete' do
    #   port = Attribution::Portfolio.create! name: "bodhi"
    #
    #   d0 = Date.civil( 2015, 2, 18 )
    #   d1 = d0 + 1
    #
    #   day1 = port.days.create! :date => d1
    #   day0 = port.days.create! :date => d0
    #
    #   holdings1 = [
    #     { market_value:  40, cusip: "1", ticker: "A", day_id: day1.id },
    #     { market_value:  50, cusip: "2", ticker: "B", day_id: day1.id },
    #     { market_value: 110, cusip: "3", ticker: "C", day_id: day1.id }
    #   ]
    #
    #   holdings0 = [
    #     { market_value:  25, cusip: "1", ticker: "A", day_id: day0.id },
    #     { market_value:  50, cusip: "2", ticker: "B", day_id: day0.id },
    #     { market_value: 125, cusip: "3", ticker: "C", day_id: day0.id }
    #   ]
    #
    #   allow( day1 ).to receive( :holdings ).and_return( attribs_to_holdings( holdings1 ) )
    #   allow( day1 ).to receive( :transactions ).and_return( [] )
    #
    #   allow( day0 ).to receive( :prev_holdings ).and_return( attribs_to_holdings( holdings0 ) )
    #   allow( day0 ).to receive( :prev_transactions ).and_return( [] )
    #
    #   allow_any_instance_of( Attribution::Day ).to receive( :ensure_download ).and_return( true )
    #
    #   report = Attribution::Report.new portfolio: port, start_date: d1, end_date: d1
    #   report.calculate
    #   original_day_count = port.days.size
    #   report.calculate
    #   expect( port.days.size ).to eq( original_day_count )
    # end
    
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
    
  #   it 'should check to see if it needs to download transactions before calculating' do
  #     date = Date.civil(2015, 2, 19)
  #     portfolio_name = "bodhi"
  #     portfolio = Attribution::Portfolio.where( name: portfolio_name ).first_or_create
  #     report = Attribution::Report.new portfolio: portfolio,
  #                                     start_date: date,
  #                                       end_date: date
  #     expect( report ).to receive(:ensure_days_are_completely_downloaded)
  #     report.calculate
  #   end
  #
  #   it 'should ensure data is downloaded for the day prior to the start date' do
  #     date = Date.civil(2015, 2, 19)
  #     portfolio_name = "bodhi"
  #     portfolio = Attribution::Portfolio.where( name: portfolio_name ).first_or_create
  #     report = Attribution::Report.new portfolio: portfolio,
  #                                     start_date: date,
  #                                       end_date: date
  #
  #     allow( report ).to receive( :calculate_days ).and_return( true )
  #     allow( report ).to receive( :security_stats ).and_return( {} )
  #     expect( report ).to receive( :ensure_day_is_downloaded ).with( date ).and_return( true )
  #     expect( report ).to receive( :ensure_day_is_downloaded ).with( date-1 ).and_return( true )
  #     report.calculate
  #   end
  #
  #   it 'should create holdings for a day if it has not been downloaded yet' do
  #     portfolio_name = "bodhi"
  #     date = Date.civil(2015, 2, 19)
  #
  #     holdings = {
  #       :portfolio_name=>"Daruma Bodhi Fund, LP",
  #       :date=>date,
  #       :account_number=>nil,
  #       :holdings => [
  #         {:quantity=>243725.0, :ticker=>"ACXM", :cusip=>"005125109", :security=>"Acxiom", :unit_cost=>16.93, :total_cost=>4126634.93, :price=>19.76, :market_value=>4816006.0, :pct_assets=>3.8, :yield=>0.0},
  #         {:quantity=>77928.0, :ticker=>"ALGN", :cusip=>"016255101", :security=>"Align Technology", :unit_cost=>51.05, :total_cost=>3978052.21, :price=>56.81, :market_value=>4427089.68, :pct_assets=>3.5, :yield=>0.0},
  #         {:quantity=>78053.0, :ticker=>"AVY", :cusip=>"053611109", :security=>"Avery-Dennison", :unit_cost=>30.53, :total_cost=>2383159.17, :price=>53.8, :market_value=>4199251.4, :pct_assets=>3.3, :yield=>2.6},
  #         {:quantity=>50709.0, :ticker=>"BDC", :cusip=>"077454106", :security=>"Belden", :unit_cost=>71.69, :total_cost=>3635108.09, :price=>88.52, :market_value=>4488760.68, :pct_assets=>3.5, :yield=>0.3},
  #         {:quantity=>78789.0, :ticker=>"BC", :cusip=>"117043109", :security=>"Brunswick", :unit_cost=>23.05, :total_cost=>1816338.33, :price=>54.84, :market_value=>4320788.76, :pct_assets=>3.4, :yield=>0.7},
  #         {:quantity=>190430.0, :ticker=>"CDNS", :cusip=>"127387108", :security=>"Cadence Design", :unit_cost=>9.29, :total_cost=>1768630.8, :price=>18.23, :market_value=>3471538.9, :pct_assets=>2.7, :yield=>0.0},
  #         {:quantity=>147438.0, :ticker=>"DGI", :cusip=>"25389M877", :security=>"Digitalglobe", :unit_cost=>28.4, :total_cost=>4186949.55, :price=>30.55, :market_value=>4504230.9, :pct_assets=>3.5, :yield=>0.0},
  #         {:quantity=>97413.0, :ticker=>"FBHS", :cusip=>"34964C106", :security=>"Fortune Brands", :unit_cost=>29.9, :total_cost=>2912389.51, :price=>47.78, :market_value=>4654393.14, :pct_assets=>3.6, :yield=>1.0},
  #         {:quantity=>189939.0, :ticker=>"FRAN", :cusip=>"351793104", :security=>"Francesca's Holdings", :unit_cost=>22.22, :total_cost=>4221022.59, :price=>15.18, :market_value=>2883274.02, :pct_assets=>2.3, :yield=>0.0},
  #         {:quantity=>101523.0, :ticker=>"FUL", :cusip=>"359694106", :security=>"H.B. Fuller Co.", :unit_cost=>46.44, :total_cost=>4714774.95, :price=>44.28, :market_value=>4495438.44, :pct_assets=>3.5, :yield=>1.1},
  #         {:quantity=>100077.0, :ticker=>"HLS", :cusip=>"421924309", :security=>"Healthsouth", :unit_cost=>21.58, :total_cost=>2160045.08, :price=>44.91, :market_value=>4494458.07, :pct_assets=>3.5, :yield=>1.6},
  #         {:quantity=>143089.0, :ticker=>"LYV", :cusip=>"538034109", :security=>"Live Nation", :unit_cost=>12.75, :total_cost=>1824647.31, :price=>25.42, :market_value=>3637322.38, :pct_assets=>2.9, :yield=>0.0},
  #         {:quantity=>61491.0, :ticker=>"LL", :cusip=>"55003T107", :security=>"Lumber Liquidators", :unit_cost=>56.52, :total_cost=>3475451.88, :price=>67.44, :market_value=>4146953.04, :pct_assets=>3.3, :yield=>0.0},
  #         {:quantity=>57289.0, :ticker=>"MFRM", :cusip=>"57722W106", :security=>"Mattress Firm Holding", :unit_cost=>60.13, :total_cost=>3444764.51, :price=>59.46, :market_value=>3406403.94, :pct_assets=>2.7, :yield=>0.0},
  #         {:quantity=>55725.0, :ticker=>"MD", :cusip=>"58502B106", :security=>"Mednax", :unit_cost=>33.16, :total_cost=>1847912.32, :price=>70.92, :market_value=>3952017.0, :pct_assets=>3.1, :yield=>0.0},
  #         {:quantity=>48298.0, :ticker=>"NXPI", :cusip=>"N6596X109", :security=>"NXP Semiconductor", :unit_cost=>29.69, :total_cost=>1433942.12, :price=>85.67, :market_value=>4137689.66, :pct_assets=>3.2, :yield=>0.0},
  #         {:quantity=>136186.0, :ticker=>"NATI", :cusip=>"636518102", :security=>"Natl Instruments", :unit_cost=>27.54, :total_cost=>3750443.54, :price=>31.0, :market_value=>4221766.0, :pct_assets=>3.3, :yield=>1.9},
  #         {:quantity=>110772.0, :ticker=>"OC", :cusip=>"690742101", :security=>"Owens Corning", :unit_cost=>39.92, :total_cost=>4421776.69, :price=>40.68, :market_value=>4506204.96, :pct_assets=>3.5, :yield=>1.6},
  #         {:quantity=>36102.0, :ticker=>"PVH", :cusip=>"693656100", :security=>"PVH Corp.", :unit_cost=>118.77, :total_cost=>4287973.58, :price=>108.52, :market_value=>3917789.04, :pct_assets=>3.1, :yield=>0.1},
  #         {:quantity=>34735.0, :ticker=>"PCRX", :cusip=>"695127100", :security=>"Pacira Pharmaceuticals", :unit_cost=>49.42, :total_cost=>1716643.21, :price=>115.63, :market_value=>4016234.38, :pct_assets=>3.1, :yield=>0.0},
  #         {:quantity=>39121.0, :ticker=>"PLL", :cusip=>"696429307", :security=>"Pall", :unit_cost=>48.76, :total_cost=>1907435.23, :price=>104.22, :market_value=>4077190.62, :pct_assets=>3.2, :yield=>1.1},
  #         {:quantity=>23756.0, :ticker=>"PRGO", :cusip=>"G97822103", :security=>"Perrigo", :unit_cost=>106.78, :total_cost=>2536655.68, :price=>151.59, :market_value=>3601172.04, :pct_assets=>2.8, :yield=>0.3},
  #         {:quantity=>173735.0, :ticker=>"PBI", :cusip=>"724479100", :security=>"Pitney Bowes Inc.", :unit_cost=>23.24, :total_cost=>4036820.89, :price=>22.75, :market_value=>3952471.25, :pct_assets=>3.1, :yield=>3.3},
  #         {:quantity=>121385.0, :ticker=>"QEP", :cusip=>"74733V100", :security=>"QEP Resources", :unit_cost=>30.76, :total_cost=>3734123.66, :price=>22.79, :market_value=>2766364.15, :pct_assets=>2.2, :yield=>0.3},
  #         {:quantity=>423668.0, :ticker=>"STNG", :cusip=>"Y7542C106", :security=>"Scorpio Tankers", :unit_cost=>10.5, :total_cost=>4449120.24, :price=>8.27, :market_value=>3503734.36, :pct_assets=>2.7, :yield=>4.4},
  #         {:quantity=>112120.0, :ticker=>"SPN", :cusip=>"868157108", :security=>"Superior Energy Svcs", :unit_cost=>23.46, :total_cost=>2629909.14, :price=>22.04, :market_value=>2471124.8, :pct_assets=>1.9, :yield=>0.0},
  #         {:quantity=>35418.0, :ticker=>"UHS", :cusip=>"913903100", :security=>"Universal Health Svcs", :unit_cost=>62.65, :total_cost=>2219107.71, :price=>107.18, :market_value=>3796101.24, :pct_assets=>3.0, :yield=>0.2},
  #         {:quantity=>31657.0, :ticker=>"WEX", :cusip=>"96208T104", :security=>"WEX", :unit_cost=>42.37, :total_cost=>1341266.62, :price=>103.57, :market_value=>3278715.49, :pct_assets=>2.6, :yield=>0.0},
  #         {:quantity=>47200.0, :ticker=>"WCG", :cusip=>"94946T106", :security=>"Wellcare Health Plans", :unit_cost=>51.48, :total_cost=>2430006.91, :price=>82.73, :market_value=>3904856.0, :pct_assets=>3.1, :yield=>0.0},
  #         {:quantity=>105244.0, :ticker=>"XYL", :cusip=>"98419M100", :security=>"Xylem Inc.", :unit_cost=>36.76, :total_cost=>3869022.03, :price=>35.66, :market_value=>3753001.04, :pct_assets=>2.9, :yield=>1.4}
  #       ],
  #       :total_holdings=>{
  #         :total_cost=>91260128.47,
  #         :market_value=>117802341.38,
  #         :pct_assets=>92.4,
  #         :yield=>0.8
  #       },
  #       :cash_and_equivalents=>{
  #         :total_cost=>9718317.75,
  #         :market_value=>9718317.75,
  #         :pct_assets=>7.6,
  #         :yield=>0.1
  #       },
  #       :cash=>{:total_cost=>9781955.52, :market_value=>9781955.52, :pct_assets=>7.7, :yield=>0.1},
  #       :cash_items=>{
  #         :acctfeepay=>{:code=>"acctfeepay", :name=>"Accounting Fee Payable", :total_cost=>-42875.0, :market_value=>-42875.0, :pct_assets=>0.0, :yield=>0.0},
  #         :divacc=>{:code=>"divacc", :name=>"Accrued Dividend Income", :total_cost=>94170.5, :market_value=>94170.5, :pct_assets=>0.1, :yield=>0.0},
  #         :adminfeepay=>{:code=>"adminfeepay", :name=>"Admin Fee Payable", :total_cost=>-70854.14, :market_value=>-70854.14, :pct_assets=>-0.1, :yield=>0.0},
  #         :cash=>{:code=>"cash", :name=>"Cash", :total_cost=>9781955.52, :market_value=>9781955.52, :pct_assets=>7.7, :yield=>0.1},
  #         :custfeepay=>{:code=>"custfeepay", :name=>"Custodian Fee Payable", :total_cost=>-10593.35, :market_value=>-10593.35, :pct_assets=>0.0, :yield=>0.0},
  #         :legalfeepay=>{:code=>"legalfeepay", :name=>"Legal Fee Payable", :total_cost=>-6638.96, :market_value=>-6638.96, :pct_assets=>0.0, :yield=>0.0},
  #         :redpay=>{:code=>"redpay", :name=>"Redemptions Payable", :total_cost=>-24576.82, :market_value=>-24576.82, :pct_assets=>0.0, :yield=>0.0},
  #         :ticketfeepay=>{:code=>"ticketfeepay", :name=>"Ticket Fees Payable", :total_cost=>-2270.0, :market_value=>-2270.0, :pct_assets=>0.0, :yield=>0.0}
  #       },
  #       :dividends=>{:total_cost=>94170.5, :market_value=>94170.5, :pct_assets=>0.1, :yield=>0.0},
  #       :total=>{:total_cost=>100978446.22, :market_value=>127520659.13, :pct_assets=>100.0, :yield=>0.7}
  #     }
  #     allow_any_instance_of( Axys::AppraisalWithTickerAndCusipReport ).to receive(:run!).and_return( holdings )
  #     allow_any_instance_of( Axys::AppraisalWithTickerAndCusipReport ).to receive(:attribs).and_return( holdings )
  #
  #     transactions = {
  #       :transactions => [
  #         {:code=>"wd", :security=>"Accrued Dividend Income", :trade_date=>date, :settle_date=>date, :sd_type=>"caus", :sd_symbol=>"cash", :trade_amount=>12182.76, :cusip=>nil, :symbol=>"divacc"}
  #       ],
  #       :stock=>[],
  #       :cash=>[],
  #       :divs=>[],
  #       :other=> [
  #         {:code=>"wd", :security=>"Accrued Dividend Income", :trade_date=>date, :settle_date=>date, :sd_type=>"caus", :sd_symbol=>"cash", :trade_amount=>12182.76, :cusip=>nil, :symbol=>"divacc"}
  #       ]
  #     }
  #
  #     allow_any_instance_of( Axys::TransactionsWithSecuritiesReport ).to receive(:run!).and_return( transactions )
  #     allow_any_instance_of( Axys::TransactionsWithSecuritiesReport ).to receive(:attribs).and_return( transactions )
  #
  #     portfolio = Attribution::Portfolio.create! :name  => portfolio_name
  #     report = Attribution::Report.new :portfolio  => portfolio,
  #                                       :start_date => date,
  #                                       :end_date   => date
  #     portfolio.clear_data_on date
  #     expect( portfolio.days.where( :date => date ) ).to be_empty
  #     report.calculate
  #     expect( portfolio.days.where( :date => date ) ).to_not be_empty
  #     expect( portfolio.days.where( :date => date ).first.security_days ).to_not be_empty
  #   end
  
  
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
    
    it 'should only have one security day for acctfeepay', focus: true do
      puts "*** ENSURING"
      @rep.ensure_days_are_completely_downloaded
      @rep.ensure_security_days_are_completely_calculated
      puts "*** ENSURING COMPLETE"
      
      acctfeepay_holding_codes = Attribution::HoldingCode.where( :name => "acctfeepay" ).all
      expect( acctfeepay_holding_codes.size ).to eq( 1 )
      
      hc = acctfeepay_holding_codes.first
      
      companies = Attribution::Company.where( code_id: hc.id ).all
      expect( companies.size ).to eq( 1 )
      sds = Attribution::SecurityDay.all
      sds.each do |sd|
        puts "value of sd is: #{sd.inspect}"
      end
      puts "value of sds.size is: #{sds.size.inspect}"
      c = companies.first
      puts "value of c is: #{c.inspect}"
      puts "value of c.security_days is: #{c.security_days.inspect}"
      expect( c.security_days.size ).to eq( 1 )
    end

    it 'should properly calculate cumulative performances ' do
      @rep.calculate

      d = @rep.days.last
      d.print_holdings d.holdings
    
      rep.audit

      expect( '%0.8f' % @rep.cumulative_security_performances["TFM"] ).to eq("1.03708333")
      expect( '%0.8f' % @rep.cumulative_security_performances["SPF"] ).to eq("0.97977244")
      expect( '%0.8f' % @rep.cumulative_security_performances["cash"] ).to eq("1.0")
      expect( '%0.8f' % @rep.cumulative_security_performances["divacc"] ).to eq("1.0")
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