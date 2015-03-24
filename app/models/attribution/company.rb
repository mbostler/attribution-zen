# == Schema Information
#
# Table name: attribution_companies
#
#  id           :integer          not null, primary key
#  name         :string
#  cusip        :string
#  ticker       :string
#  code_id      :integer
#  effective_on :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Attribution::Company < ActiveRecord::Base
  belongs_to :code, class_name: "Attribution::HoldingCode"
  has_many :security_days, class_name: "Attribution::SecurityDay", dependent: :destroy
  
  def tag
    self.ticker || self.code.name
  end
  
  def self.find_by_tag( tag )
    c = where( ticker: tag ).first
    return c unless c.nil?
    
    hc = Attribution::HoldingCode.where( name: tag ).first
    where( code_id: hc.id ).first
  end
end
