# == Schema Information
#
# Table name: attribution_transaction_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::TransactionType, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end