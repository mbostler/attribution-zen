# == Schema Information
#
# Table name: attribution_holdings
#
#  id           :integer          not null, primary key
#  quantity     :float
#  ticker       :string
#  cusip        :string
#  security     :string
#  unit_cost    :float
#  total_cost   :float
#  price        :float
#  market_value :float
#  pct_assets   :float
#  yield        :float
#  company_id   :integer
#  code         :string
#  type_id      :integer
#  day_id       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::Holding, :type => :model do
  it 'should associate a company when saving' do
    ticker = "ABC"
    name = "Alpha Beta Cy"
    cusip = "029872B15"
    attribs = { ticker: ticker, name: name, cusip: cusip }
    
    h = Attribution::Holding.create! attribs
    expect( h.company.name ).to eq( name )
    expect( h.company.ticker ).to eq( ticker )
    expect( h.company.cusip ).to eq( cusip )
  end
  
  it 'knows its portfolio weight' do
    d = Attribution::Day.create!
    h = d.holdings.create! market_value: 5
    
    allow_any_instance_of( Attribution::Day ).to receive(:ensure_download).and_return( true )
    allow_any_instance_of( Attribution::Day ).to receive(:total_market_value).and_return( 50 )
    expect( h.portfolio_weight ).to eq( 0.1 )
  end
end
