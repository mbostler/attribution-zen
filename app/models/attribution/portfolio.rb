class Attribution::Portfolio < ActiveRecord::Base
  attr_accessor :returns
  attr_reader :total_performance

  def initialize
    @returns = Attribution::PortfolioReturns.new
  end
  
  def calculate
    @total_performance = @returns.total
  end
  
end
