# == Schema Information
#
# Table name: attribution_days
#
#  id         :integer          not null, primary key
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::Day, :type => :model do
  before(:all) do
    d = Date.civil 2015, 2, 5
    @day = Attribution::Day.create! :date => d
  end
  
  it 'should have a previous day' do
    expect(@day.prev_day.date).to eq(@day.date-1)
  end

  it 'should have a next day' do
    expect(@day.next_day.date).to eq(@day.date+1)
  end
  
end
