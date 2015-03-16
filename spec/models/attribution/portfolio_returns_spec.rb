require 'rails_helper'

RSpec.describe Attribution::PortfolioReturns, :type => :model do
  it "should respond to []" do
    rets = Attribution::PortfolioReturns.new
    expect { rets[0] }.to_not raise_error
  end

  it "should respond to []=" do
    rets = Attribution::PortfolioReturns.new
    rets[0] = 5
    expect( rets[0] ).to eq(5)
  end
  
  it 'should automatically convert returns data to numeric' do
    rets = Attribution::PortfolioReturns.new
    rets[0] = "5"
    expect( rets[0].is_a?( Numeric ) ).to eq(true)
  end
  
  it 'should calculate a total' do
    rets = Attribution::PortfolioReturns.new
    rets[0] = 1.5
    rets[1] = 1.5
    expect( rets.total ).to eq( 2.25 )
  end
  
end
