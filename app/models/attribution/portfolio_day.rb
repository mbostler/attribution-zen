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

class Attribution::PortfolioDay < ActiveRecord::Base
end
