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

class Attribution::SecurityDay < ActiveRecord::Base
  belongs_to :company, class_name: "Attribution::Company"
  belongs_to :day, :class_name => "Attribution::Day"
  before_save :link_security_data
  
  def link_security_data
    if !!self.company && self.company.cusip == self.cusip
      return
    else
      c = Attribution::Company.
              where( :cusip => cusip ).
              first_or_create
      self.company = c
    end
  end
  
  def date
    self.day and self.day.date
  end
  
  def ticker
    self.company.ticker
  end
end
