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
  has_many :security_days, class_name: "Attribution::SecurityDay"
  
  def tag
    self.ticker || self.code
  end
end
