# == Schema Information
#
# Table name: attribution_transaction_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attribution::TransactionType < ActiveRecord::Base
end
