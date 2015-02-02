require 'rails_helper'

RSpec.describe Attribution::Portfolio, :type => :model do
  it 'should initialize with a proper PortfolioReturns set' do
    port = Attribution::Portfolio.new
    expect( port.returns.class ).to eq(Attribution::PortfolioReturns)
  end
  
end
