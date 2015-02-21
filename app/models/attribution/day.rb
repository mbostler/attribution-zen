# == Schema Information
#
# Table name: attribution_days
#
#  id           :integer          not null, primary key
#  date         :date
#  portfolio_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

module Attribution
  class Day < ActiveRecord::Base
    belongs_to :portfolio, :class_name => "Attribution::Portfolio"
    has_many :security_days, :class_name => "Attribution::SecurityDay"
    has_one :portfolio_day, :class_name => "Attribution::PortfolioDay"
    has_one :prev_day, -> { where( :date => self.date-1) }, :class_name => "Attribution::Day"
    has_one :next_day, -> { where( :date => self.date+1) }, :class_name => "Attribution::Day"
    has_many :holdings, class_name: "Attribution::Holding"
    has_many :transactions, class_name: "Attribution::Transaction"
  
    def create_data_file
      df = Attribution::DataFile.new( self ).create
    end
  
    def prev_day
      Attribution::Day.where(:date => self.date-1, :portfolio_id => self.portfolio_id).first_or_create
    end
  
    def next_day
      Attribution::Day.where(:date => self.date+1, :portfolio_id => self.portfolio_id).first_or_create
    end

    def completed?
      !!self.portfolio_day && !!self.portfolio_day.performance
    end
    
    def download
      raise_error_if_no_portfolio_assigned
      raise_error_if_no_date_assigned
      download_holdings
      download_transactions
    end
    
    def raise_error_if_no_portfolio_assigned
      if portfolio.nil? || portfolio.name.blank?
        raise ArgumentError, "Attribution::Day cannot download as there is no assigned portfolio name (day is: #{self.inspect} and portfolio is: #{self.portfolio.inspect})"
      end
    end
    
    def raise_error_if_no_date_assigned
      if self.date.nil?
        raise ArgumentError, "Attribution::Day cannot download as there is no assigned date (day is: #{self.inspect})"
      end
    end
    
    def download_holdings
      portfolio_name = portfolio.name
      rep = Axys::AppraisalWithTickerAndCusipReport.new :portfolio => portfolio
      rep.run! :remote => true
      rep[:holdings].each do |holding|
        holding_type = Attribution::HoldingType.where( name: Attribution::HoldingType::SECURITY_NAME ).first_or_create
        attribs = holding.merge type_id: holding_type.id
        holdings.create! attribs
      end
      
      rep[:cash_items].each do |code, cash_item|
        holding_type = Attribution::HoldingType.where( name: Attribution::HoldingType::CASH_NAME ).first_or_create
        attribs = cash_item.merge type_id: holding_type.id
        holdings.create! attribs        
      end
    end
    
    def download_transactions
      portfolio_name = portfolio.name
      rep = Axys::TransactionsWithSecuritiesReport.new portfolio: portfolio, start: self.date, end: self.date
      rep.run! :remote => true
      
      rep[:transactions].each do |transaction|
        transactions.create! transaction
      end
    end
    
    def prev_holdings
      prev_day.holdings
    end
    
    def prev_transactions
      prev_day.transactions
    end
    
    def total_market_value
      ensure_download
      self.holdings.inject( BigDecimal( "0.0") ) { |s, h| s += h.market_value }
    end
    
    def ensure_download
      return true if self.completed?
      download
    end
    
  end
end
