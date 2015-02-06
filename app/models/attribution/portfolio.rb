# == Schema Information
#
# Table name: attribution_portfolios
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attribution::Portfolio < ActiveRecord::Base
  attr_accessor :returns
  attr_reader :total_performance
  has_many :days, :class_name => "Attribution::Day"

  after_initialize :set_portfolio_returns
  
  def set_portfolio_returns
    @returns = Attribution::PortfolioReturns.new
  end
  
  def calculate
    @total_performance = @returns.total
  end
  
end
