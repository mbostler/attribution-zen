# == Schema Information
#
# Table name: attribution_transactions
#
#  id           :integer          not null, primary key
#  code         :string
#  security     :string
#  quantity     :integer
#  trade_date   :date
#  settle_date  :date
#  sd_type      :string
#  sd_symbol    :string
#  trade_amount :float
#  cusip        :string
#  symbol       :string
#  day_id       :integer
#  company_id   :integer
#  close_method :string
#  lot          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::Transaction, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
