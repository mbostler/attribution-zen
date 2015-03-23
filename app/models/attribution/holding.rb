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

class Attribution::Holding < ActiveRecord::Base
  PRINT_SETTINGS = {
    :quantity => 12,
    :ticker => 6,
    :cusip => 10,
    :date => 10,
    :security => 15,
    :market_value => 14,
    :price => 7,
    :code_name => 15,
    :type_name => 10
  }
  belongs_to :day, class_name: "Attribution::Day"
  belongs_to :company, class_name: "Attribution::Company"
  belongs_to :type, class_name: "Attribution::HoldingType"
  belongs_to :code, class_name: "Attribution::HoldingCode"
  attr_accessor :name
  before_save :associate_company
  
  def associate_company
    c = Attribution::Company.where( name: self.name, ticker: self.ticker, cusip: self.cusip, code_id: self.code_id ).first_or_create!
    self.company_id = c.id
  end
  
  def portfolio_weight
    self.market_value / day.total_market_value
  end
  
  def print
    str_parts = PRINT_SETTINGS.map do |attrib, len|
      self.send(attrib).to_s[0,len].rjust( len )
    end
    
    str = str_parts.join( " | " )
    puts str
  end
  
  def date
    self.day.date
  end
  
  def type_name
    type and type.name
  end
  
  def usable?
    return true if code.nil?
    code.usable?
  end
  
  def code_name
    code and code.name
  end
  
  def tag
    company.id
    # cusip || code.name
  end
  
end
