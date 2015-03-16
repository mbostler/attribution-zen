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

require 'rails_helper'

RSpec.describe Attribution::Company, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
