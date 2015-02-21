# == Schema Information
#
# Table name: attribution_portfolios
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  human_name     :string
#  account_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::Portfolio, :type => :model do
  it 'should initialize with a proper PortfolioReturns set' do
    port = Attribution::Portfolio.new
    expect( port.returns.class ).to eq(Attribution::PortfolioReturns)
  end
  
end
