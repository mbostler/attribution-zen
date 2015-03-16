# == Schema Information
#
# Table name: attribution_portfolios
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  human_name     :string
#  account_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Attribution::Portfolio < ActiveRecord::Base
  attr_accessor :returns
  attr_reader :total_performance
  has_many :days, :class_name => "Attribution::Day"
  has_many :holdings, :through => :days
  has_many :transactions, :through => :days

  after_initialize :set_portfolio_returns
  
  def set_portfolio_returns
    @returns = Attribution::PortfolioReturns.new
  end
  
  def calculate
    @total_performance = @returns.total
  end
  
  def day( date )
    days.where( :date => date ).first_or_create!
  end

  def clear_data_on( date )
    days.where( :date => date ).destroy_all
  end
  
  def holdings_on( date )
    day( date ).holdings
  end
  
  def transactions_on( date )
    day( date ).holdings
  end
end
