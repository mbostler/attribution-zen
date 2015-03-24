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
    has_many :security_days, :class_name => "Attribution::SecurityDay", :dependent => :destroy
    has_one :portfolio_day, :class_name => "Attribution::PortfolioDay", :dependent => :destroy
    has_one :prev_day, -> { where( :date => self.date-1) }, :class_name => "Attribution::Day"
    has_one :next_day, -> { where( :date => self.date+1) }, :class_name => "Attribution::Day"
    has_many :holdings, class_name: "Attribution::Holding", dependent: :destroy
    has_many :transactions, class_name: "Attribution::Transaction", dependent: :destroy
  
    def create_data_file
      df = Attribution::DataFile.new( self ).create
    end
  
    def prev_day
      Attribution::Day.where(:date => self.date.prev_trading_day, :portfolio_id => self.portfolio_id).first_or_create
    end
  
    def next_day
      Attribution::Day.where(:date => self.date.next_trading_day, :portfolio_id => self.portfolio_id).first_or_create
    end

    def completed?
      !!self.portfolio_day && !!self.portfolio_day.performance
    end
    
    def downloaded?
      holdings.any?
    end
    
    def download
      return if downloaded?
      raise_error_if_no_portfolio_assigned
      raise_error_if_no_date_assigned
      ActiveRecord::Base.transaction do
        download_holdings
        download_transactions        
      end
    end
    
    def usable_holdings
      holdings.select(&:usable?)
    end
    
    def usable_prev_holdings
      prev_holdings.select(&:usable?)
    end
    
    def compute_portfolio_day
      puts "***TXNS***"
      puts "value of transactions is: #{transactions.inspect}"
      # adj_txns = transactions + transactions.inject([]) do |adjs, txn|
      #   adjs << Attribution::Transaction.build( )
      # end
      puts "usable_holdings is : " + usable_holdings.inspect
      puts "usable_prev_holdings is : " + usable_prev_holdings.inspect
      puts "transactions is : " + transactions.inspect
      perf = Attribution::PerformanceCalculator.calc :holdings => usable_holdings, 
                                                     :prev_holdings => usable_prev_holdings, 
                                                     :transactions => transactions,
                                                     :treat_as_total => true
      pd = self.create_portfolio_day! :performance => perf
      pd
    end
    
    def refresh!
      holdings.destroy_all
      transactions.destroy_all
      security_days.destroy_all
      portfolio_day.destroy
      download
      compute_security_days
    end
    
    def compute_security_days
      download unless downloaded?
      calculator = Attribution::SecurityPerformanceCalculator.new :day => self
      calculator.calculate
      compute_portfolio_day
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
      puts "downloading holdings for #{portfolio_name} on #{self.date}"
      
      rep = Axys::AppraisalWithTickerAndCusipReport.run! :portfolio_name => portfolio.name, start: self.date
      rep[:holdings].each do |holding|
        holding_type = Attribution::HoldingType.where( name: Attribution::HoldingType::SECURITY_NAME ).first_or_create
        holding_code = Attribution::HoldingCode.where( name: holding[:code] ).first_or_create if !holding[:code].blank?
        attribs = holding.merge type_id: holding_type.id, code: holding_code
        holdings.create! attribs
      end
      
      rep[:cash_items].each do |code, cash_item|
        holding_type = Attribution::HoldingType.where( name: Attribution::HoldingType::CASH_NAME ).first_or_create
        holding_code = Attribution::HoldingCode.where( name: cash_item[:code] ).first_or_create if !cash_item[:code].blank?
        attribs = cash_item.merge type_id: holding_type.id, code: holding_code
        holdings.create! attribs        
      end
    end
    
    def download_transactions
      portfolio_name = portfolio.name
      start_date = self.date.prev_trading_day+1
      puts "downloading transactions for #{portfolio_name} on #{start_date}-#{self.date}"
      rep = Axys::TransactionsWithSecuritiesReport.run! portfolio_name: portfolio.name, start: start_date, end: self.date
      
      rep[:transactions].each do |transaction|
        intacc_code = "intacc"
        company = if transaction[:sd_symbol] == intacc_code || transaction[:symbol] == intacc_code
          hc = Attribution::HoldingCode.where( name: intacc_code ).first_or_create
          Attribution::Company.where( code_id: hc.id ).first_or_create
        else
          Attribution::Company.where( ticker: transaction[:symbol], cusip: transaction[:cusip] ).first_or_create
        end
        transactions.create! transaction.merge( company_id: company.id )
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
      puts "self.usable_holdings is : " + self.usable_holdings.inspect
      self.usable_holdings.inject( BigDecimal( "0.0") ) { |s, h| s += h.market_value }
      # puts "usable holdings!:"
      # print_holdings( self.usable_holdings )
    end
    
    def ensure_download
      return true if self.completed?
      download
    end
    
    def print_holdings( holdings_to_print )
      str_parts = Attribution::Holding::PRINT_SETTINGS.map do |attrib, len|
        attrib.to_s[0,len].rjust( len )
      end
      str = str_parts.join( " | " )
      puts str
      holdings_to_print.each do |h|
        h.print
      end
    end
    
    def audit_security_days
      security_days.each do |sd|
        puts [sd.company.tag, sd.performance, sd.contribution].inspect
      end
    end
    
    def audit_holdings
      holdings.each do |h|
        puts [h.company.tag, h.market_value].inspect
      end
      true
    end
    
    def audit_transactions
      transactions.each do |txn|
        puts [txn.company_id, txn.code, txn.symbol, txn.trade_amount, txn.sd_symbol, txn.trade_date].inspect
      end
      true
    end
    
  end
end
