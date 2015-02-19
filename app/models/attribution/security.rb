# == Schema Information
#
# Table name: attribution_securities
#
#  id           :integer          not null, primary key
#  cusip        :string
#  ticker       :string
#  effective_on :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Attribution::Security < ActiveRecord::Base
end
