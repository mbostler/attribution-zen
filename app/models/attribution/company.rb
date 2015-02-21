# == Schema Information
#
# Table name: attribution_companies
#
#  id         :integer          not null, primary key
#  name       :string
#  cusip      :string
#  ticker     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attribution::Company < ActiveRecord::Base
end
