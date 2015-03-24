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
#  code_id      :integer
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
  
  it 'knows whether or not it is usable' do
    excluded_types = %w(acctfeepay adminfeepay custfeepay manfeepay ticketfeepay)
    excluded_types.each do |ex_type|
      code = Attribution::HoldingCode.new :name => ex_type
      h = Attribution::Holding.new :code => code
      expect( h.usable? ).to eq(false)
    end

    included_types = %w(divacc intacc cash redpay legalfeepay)
    included_types.each do |in_type|
      code = Attribution::HoldingCode.new :name => in_type
      h = Attribution::Holding.new :code => code
      expect( h.usable? ).to eq(true)
    end
    
    h = Attribution::Holding.new :code => nil
    expect( h.usable? ).to eq(true)
  end
  
  it 'should properly distinguish its cash type' do
    cash_type = Attribution::HoldingType.where( name: "Cash" ).first_or_create
    non_cash_type = Attribution::HoldingType.where( name: "Security" ).first_or_create
    
    cash_holding = Attribution::Holding.new type_id: cash_type.id
    non_cash_holding = Attribution::Holding.new type_id: non_cash_type.id
    
    expect( cash_holding.cash_type? ).to eq(true)
    expect( non_cash_holding.cash_type? ).to eq(false)
  end
end
