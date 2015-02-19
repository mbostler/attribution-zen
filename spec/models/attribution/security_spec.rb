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

require 'rails_helper'

RSpec.describe Attribution::Security, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
