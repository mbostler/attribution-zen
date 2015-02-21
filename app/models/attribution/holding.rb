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

class Attribution::Holding < ActiveRecord::Base
  belongs_to :day, class_name: "Attribution::Day"
  belongs_to :company, class_name: "Attribution::Company"
  attr_accessor :name
  before_save :associate_company
  
  def associate_company
    c = Attribution::Company.where( name: self.name, ticker: self.ticker, cusip: self.cusip ).first_or_create!
    self.company_id = c.id
  end
  
  def portfolio_weight
    self.market_value / day.total_market_value
  end
  
end
