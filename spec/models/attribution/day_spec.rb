# == Schema Information
#
# Table name: attribution_days
#
#  id           :integer          not null, primary key
#  date         :date
#  portfolio_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::Day, :type => :model do
  before(:all) do
    @port = Attribution::Portfolio.create! name: "bodhi"
    d = Date.civil 2015, 2, 5
    @day = Attribution::Day.create! :date => d, :portfolio_id => @port.id
  end
  
  it 'should have a previous day' do
    expect(@day.prev_day.date).to eq(@day.date-1)
    expect(@day.prev_day.portfolio).to eq(@day.portfolio)
  end

  it 'should have a next day' do
    expect(@day.next_day.date).to eq(@day.date+1)
    expect(@day.next_day.portfolio).to eq(@day.portfolio)
  end
  
  it 'should be able to check if a day is completely downloaded' do
    port = Attribution::Portfolio.create! name: "bodhi"
    d = Date.civil 2015, 2, 19
    day = Attribution::Day.create! :date => d, :portfolio_id => @port.id
    expect( day.completed? ).to eq(false)
    day.create_portfolio_day! :performance => 1.05
    expect( day.completed? ).to eq(true)
  end
  
  
  describe 'when downloading data' do
    it 'should successfully save holdings and transactions' do
      portfolio_name = "bodhi"
      date = Date.civil 2015, 2, 19
    
      holdings = {
        :portfolio_name=>"Daruma Bodhi Fund, LP", 
        :date=>date,
        :account_number=>nil,
        :holdings => [
          {:quantity=>243725.0, :ticker=>"ACXM", :cusip=>"005125109", :security=>"Acxiom", :unit_cost=>16.93, :total_cost=>4126634.93, :price=>19.76, :market_value=>4816006.0, :pct_assets=>3.8, :yield=>0.0},
          {:quantity=>77928.0, :ticker=>"ALGN", :cusip=>"016255101", :security=>"Align Technology", :unit_cost=>51.05, :total_cost=>3978052.21, :price=>56.81, :market_value=>4427089.68, :pct_assets=>3.5, :yield=>0.0},
          {:quantity=>78053.0, :ticker=>"AVY", :cusip=>"053611109", :security=>"Avery-Dennison", :unit_cost=>30.53, :total_cost=>2383159.17, :price=>53.8, :market_value=>4199251.4, :pct_assets=>3.3, :yield=>2.6},
          {:quantity=>50709.0, :ticker=>"BDC", :cusip=>"077454106", :security=>"Belden", :unit_cost=>71.69, :total_cost=>3635108.09, :price=>88.52, :market_value=>4488760.68, :pct_assets=>3.5, :yield=>0.3},
          {:quantity=>78789.0, :ticker=>"BC", :cusip=>"117043109", :security=>"Brunswick", :unit_cost=>23.05, :total_cost=>1816338.33, :price=>54.84, :market_value=>4320788.76, :pct_assets=>3.4, :yield=>0.7},
          {:quantity=>190430.0, :ticker=>"CDNS", :cusip=>"127387108", :security=>"Cadence Design", :unit_cost=>9.29, :total_cost=>1768630.8, :price=>18.23, :market_value=>3471538.9, :pct_assets=>2.7, :yield=>0.0},
          {:quantity=>147438.0, :ticker=>"DGI", :cusip=>"25389M877", :security=>"Digitalglobe", :unit_cost=>28.4, :total_cost=>4186949.55, :price=>30.55, :market_value=>4504230.9, :pct_assets=>3.5, :yield=>0.0},
          {:quantity=>97413.0, :ticker=>"FBHS", :cusip=>"34964C106", :security=>"Fortune Brands", :unit_cost=>29.9, :total_cost=>2912389.51, :price=>47.78, :market_value=>4654393.14, :pct_assets=>3.6, :yield=>1.0},
          {:quantity=>189939.0, :ticker=>"FRAN", :cusip=>"351793104", :security=>"Francesca's Holdings", :unit_cost=>22.22, :total_cost=>4221022.59, :price=>15.18, :market_value=>2883274.02, :pct_assets=>2.3, :yield=>0.0},
          {:quantity=>101523.0, :ticker=>"FUL", :cusip=>"359694106", :security=>"H.B. Fuller Co.", :unit_cost=>46.44, :total_cost=>4714774.95, :price=>44.28, :market_value=>4495438.44, :pct_assets=>3.5, :yield=>1.1},
          {:quantity=>100077.0, :ticker=>"HLS", :cusip=>"421924309", :security=>"Healthsouth", :unit_cost=>21.58, :total_cost=>2160045.08, :price=>44.91, :market_value=>4494458.07, :pct_assets=>3.5, :yield=>1.6},
          {:quantity=>143089.0, :ticker=>"LYV", :cusip=>"538034109", :security=>"Live Nation", :unit_cost=>12.75, :total_cost=>1824647.31, :price=>25.42, :market_value=>3637322.38, :pct_assets=>2.9, :yield=>0.0},
          {:quantity=>61491.0, :ticker=>"LL", :cusip=>"55003T107", :security=>"Lumber Liquidators", :unit_cost=>56.52, :total_cost=>3475451.88, :price=>67.44, :market_value=>4146953.04, :pct_assets=>3.3, :yield=>0.0},
          {:quantity=>57289.0, :ticker=>"MFRM", :cusip=>"57722W106", :security=>"Mattress Firm Holding", :unit_cost=>60.13, :total_cost=>3444764.51, :price=>59.46, :market_value=>3406403.94, :pct_assets=>2.7, :yield=>0.0},
          {:quantity=>55725.0, :ticker=>"MD", :cusip=>"58502B106", :security=>"Mednax", :unit_cost=>33.16, :total_cost=>1847912.32, :price=>70.92, :market_value=>3952017.0, :pct_assets=>3.1, :yield=>0.0},
          {:quantity=>48298.0, :ticker=>"NXPI", :cusip=>"N6596X109", :security=>"NXP Semiconductor", :unit_cost=>29.69, :total_cost=>1433942.12, :price=>85.67, :market_value=>4137689.66, :pct_assets=>3.2, :yield=>0.0},
          {:quantity=>136186.0, :ticker=>"NATI", :cusip=>"636518102", :security=>"Natl Instruments", :unit_cost=>27.54, :total_cost=>3750443.54, :price=>31.0, :market_value=>4221766.0, :pct_assets=>3.3, :yield=>1.9},
          {:quantity=>110772.0, :ticker=>"OC", :cusip=>"690742101", :security=>"Owens Corning", :unit_cost=>39.92, :total_cost=>4421776.69, :price=>40.68, :market_value=>4506204.96, :pct_assets=>3.5, :yield=>1.6},
          {:quantity=>36102.0, :ticker=>"PVH", :cusip=>"693656100", :security=>"PVH Corp.", :unit_cost=>118.77, :total_cost=>4287973.58, :price=>108.52, :market_value=>3917789.04, :pct_assets=>3.1, :yield=>0.1},
          {:quantity=>34735.0, :ticker=>"PCRX", :cusip=>"695127100", :security=>"Pacira Pharmaceuticals", :unit_cost=>49.42, :total_cost=>1716643.21, :price=>115.63, :market_value=>4016234.38, :pct_assets=>3.1, :yield=>0.0},
          {:quantity=>39121.0, :ticker=>"PLL", :cusip=>"696429307", :security=>"Pall", :unit_cost=>48.76, :total_cost=>1907435.23, :price=>104.22, :market_value=>4077190.62, :pct_assets=>3.2, :yield=>1.1},
          {:quantity=>23756.0, :ticker=>"PRGO", :cusip=>"G97822103", :security=>"Perrigo", :unit_cost=>106.78, :total_cost=>2536655.68, :price=>151.59, :market_value=>3601172.04, :pct_assets=>2.8, :yield=>0.3},
          {:quantity=>173735.0, :ticker=>"PBI", :cusip=>"724479100", :security=>"Pitney Bowes Inc.", :unit_cost=>23.24, :total_cost=>4036820.89, :price=>22.75, :market_value=>3952471.25, :pct_assets=>3.1, :yield=>3.3},
          {:quantity=>121385.0, :ticker=>"QEP", :cusip=>"74733V100", :security=>"QEP Resources", :unit_cost=>30.76, :total_cost=>3734123.66, :price=>22.79, :market_value=>2766364.15, :pct_assets=>2.2, :yield=>0.3},
          {:quantity=>423668.0, :ticker=>"STNG", :cusip=>"Y7542C106", :security=>"Scorpio Tankers", :unit_cost=>10.5, :total_cost=>4449120.24, :price=>8.27, :market_value=>3503734.36, :pct_assets=>2.7, :yield=>4.4},
          {:quantity=>112120.0, :ticker=>"SPN", :cusip=>"868157108", :security=>"Superior Energy Svcs", :unit_cost=>23.46, :total_cost=>2629909.14, :price=>22.04, :market_value=>2471124.8, :pct_assets=>1.9, :yield=>0.0},
          {:quantity=>35418.0, :ticker=>"UHS", :cusip=>"913903100", :security=>"Universal Health Svcs", :unit_cost=>62.65, :total_cost=>2219107.71, :price=>107.18, :market_value=>3796101.24, :pct_assets=>3.0, :yield=>0.2},
          {:quantity=>31657.0, :ticker=>"WEX", :cusip=>"96208T104", :security=>"WEX", :unit_cost=>42.37, :total_cost=>1341266.62, :price=>103.57, :market_value=>3278715.49, :pct_assets=>2.6, :yield=>0.0},
          {:quantity=>47200.0, :ticker=>"WCG", :cusip=>"94946T106", :security=>"Wellcare Health Plans", :unit_cost=>51.48, :total_cost=>2430006.91, :price=>82.73, :market_value=>3904856.0, :pct_assets=>3.1, :yield=>0.0},
          {:quantity=>105244.0, :ticker=>"XYL", :cusip=>"98419M100", :security=>"Xylem Inc.", :unit_cost=>36.76, :total_cost=>3869022.03, :price=>35.66, :market_value=>3753001.04, :pct_assets=>2.9, :yield=>1.4}
        ],
        :total_holdings=>{
          :total_cost=>91260128.47,
          :market_value=>117802341.38,
          :pct_assets=>92.4,
          :yield=>0.8
        },
        :cash_and_equivalents=>{
          :total_cost=>9718317.75, 
          :market_value=>9718317.75, 
          :pct_assets=>7.6, 
          :yield=>0.1
        },
        :cash=>{:total_cost=>9781955.52, :market_value=>9781955.52, :pct_assets=>7.7, :yield=>0.1},
        :cash_items=>{
          :acctfeepay=>{:code=>"acctfeepay", :name=>"Accounting Fee Payable", :total_cost=>-42875.0, :market_value=>-42875.0, :pct_assets=>0.0, :yield=>0.0},
          :divacc=>{:code=>"divacc", :name=>"Accrued Dividend Income", :total_cost=>94170.5, :market_value=>94170.5, :pct_assets=>0.1, :yield=>0.0},
          :adminfeepay=>{:code=>"adminfeepay", :name=>"Admin Fee Payable", :total_cost=>-70854.14, :market_value=>-70854.14, :pct_assets=>-0.1, :yield=>0.0},
          :cash=>{:code=>"cash", :name=>"Cash", :total_cost=>9781955.52, :market_value=>9781955.52, :pct_assets=>7.7, :yield=>0.1},
          :custfeepay=>{:code=>"custfeepay", :name=>"Custodian Fee Payable", :total_cost=>-10593.35, :market_value=>-10593.35, :pct_assets=>0.0, :yield=>0.0},
          :legalfeepay=>{:code=>"legalfeepay", :name=>"Legal Fee Payable", :total_cost=>-6638.96, :market_value=>-6638.96, :pct_assets=>0.0, :yield=>0.0},
          :redpay=>{:code=>"redpay", :name=>"Redemptions Payable", :total_cost=>-24576.82, :market_value=>-24576.82, :pct_assets=>0.0, :yield=>0.0},
          :ticketfeepay=>{:code=>"ticketfeepay", :name=>"Ticket Fees Payable", :total_cost=>-2270.0, :market_value=>-2270.0, :pct_assets=>0.0, :yield=>0.0}
        },
        :dividends=>{:total_cost=>94170.5, :market_value=>94170.5, :pct_assets=>0.1, :yield=>0.0},
        :total=>{:total_cost=>100978446.22, :market_value=>127520659.13, :pct_assets=>100.0, :yield=>0.7}
      }
      expect_any_instance_of( Axys::AppraisalWithTickerAndCusipReport ).to receive(:run!).and_return( holdings )
      allow_any_instance_of( Axys::AppraisalWithTickerAndCusipReport ).to receive(:attribs).and_return( holdings )
    
      transactions = {
        :transactions => [
          {:code=>"wd", :security=>"Accrued Dividend Income", :trade_date=>date, :settle_date=>date, :sd_type=>"caus", :sd_symbol=>"cash", :trade_amount=>12182.76, :cusip=>nil, :symbol=>"divacc"}
        ],
        :stock=>[],
        :cash=>[],
        :divs=>[],
        :other=> [
          {:code=>"wd", :security=>"Accrued Dividend Income", :trade_date=>date, :settle_date=>date, :sd_type=>"caus", :sd_symbol=>"cash", :trade_amount=>12182.76, :cusip=>nil, :symbol=>"divacc"}
        ]
      }

      expect_any_instance_of( Axys::TransactionsWithSecuritiesReport ).to receive(:run!).and_return( transactions )
      allow_any_instance_of( Axys::TransactionsWithSecuritiesReport ).to receive(:attribs).and_return( transactions )
      # trep = new portfolio_name: portfolio_name,
      #    start: date, end: date    
      portfolio = Attribution::Portfolio.where( name: "bodhi" ).first_or_create
      day = portfolio.days.create!( date: date )
      day.download
      expect( day.transactions.size ).to eq 1
      expect( day.holdings.size ).to eq 38
    end
    
    it 'should raise an error if there is no associated portfolio name or date' do
      day = Attribution::Day.new
      expect( day ).to receive( :download_holdings ).and_return( true )
      expect( day ).to receive( :download_transactions ).and_return( true )
      expect { day.download }.to raise_error(ArgumentError)
      day.portfolio = Attribution::Portfolio.where( name: "bodhi" ).first_or_create!
      expect { day.download }.to raise_error(ArgumentError)
      day.date = Date.civil( 2015, 2, 19)
      expect { day.download }.to_not raise_error
    end
    
    it 'should compute total market value of its securities' do
      d = Attribution::Day.new
      allow( d ).to receive( :holdings ).and_return(
        [Attribution::Holding.new( market_value: 5 ),
        Attribution::Holding.new( market_value: 7 )]
      )
      
      expect( d ).to receive( :ensure_download ).and_return( true )
      
      expect( d.total_market_value ).to eq( 12 )
    end
  end
  
end
