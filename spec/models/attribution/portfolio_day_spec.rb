# == Schema Information
#
# Table name: attribution_portfolio_days
#
#  id          :integer          not null, primary key
#  day_id      :integer
#  performance :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::PortfolioDay, :type => :model do
  it 'should properly calculate its performance when a day gets saved' do
    pending "gotta do security day specs first"
    date = Date.civil(2015, 2, 19)
    day = Attribution::Day.new( :date => date )
    holdings = [
      { market_value: 25, ticker: "A" },
      
    ]
    allow( day ).to receive(:holdings).and_return
    portfolio_day = day.portfolio_day.performance
  end
  
end
