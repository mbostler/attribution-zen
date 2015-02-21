# == Schema Information
#
# Table name: attribution_security_days
#
#  id           :integer          not null, primary key
#  cusip        :string
#  weight       :float
#  performance  :float
#  contribution :float
#  company_id   :integer
#  day_id       :integer
#  portfolio_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::SecurityDay, :type => :model do
  it 'links security to security day after saving' do
    portfolio = Attribution::Portfolio.new
    d0 = Attribution::Day.new :portfolio_id => portfolio, :date => Date.yesterday
    cusip = "ABC0001"
    sd = Attribution::SecurityDay.new :day_id => d0.id, 
                                      :cusip => cusip
    expect( sd.company.nil? ).to eq(true)
    sd.save!
    expect( sd.company.nil? ).to eq(false)    
  end
  
  it 'has a date' do
    date = Date.today
    d = Attribution::Day.new
    d.date = date
    sd = ::Attribution::SecurityDay.new :day => d
    expect( sd.date ).to eq( date )
  end
  
end
