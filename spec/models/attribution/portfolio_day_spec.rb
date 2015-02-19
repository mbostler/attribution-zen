# == Schema Information
#
# Table name: attribution_portfolio_days
#
#  id          :integer          not null, primary key
#  day_id      :integer
#  performance :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::PortfolioDay, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
