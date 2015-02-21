# == Schema Information
#
# Table name: attribution_holding_types
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attribution::HoldingType < ActiveRecord::Base
  SECURITY_NAME = "Security"
  CASH_NAME = "Cash"
end
