# == Schema Information
#
# Table name: attribution_security_days
#
#  id           :integer          not null, primary key
#  cusip        :string
#  weight       :float
#  performance  :float
#  contribution :float
#  security_id  :integer
#  day_id       :integer
#  portfolio_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Attribution::SecurityDay < ActiveRecord::Base
  belongs_to :security, :class_name => "Attribution::Security"
  belongs_to :day, :class_name => "Attribution::Day"
  before_save :link_security_data
  
  def link_security_data
    if !!self.security && self.security.cusip == self.cusip
      return
    else
      sec = Attribution::Security.
              where( :cusip => cusip ).
              order( "effective_on DESC" ).
              first_or_create
      self.security = sec
    end
  end
  
  def date
    self.day and self.day.date
  end
end
