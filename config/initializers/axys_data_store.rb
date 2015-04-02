class AxysDataStore
  
  class << self
    def thru(portfolio_name, start_date, end_date)
      ((start_date-1)..end_date).select(&:trading_day?).each do |date|
        save_date portfolio_name, date
      end
    end
  
    def save_date( portfolio_name, date )
      print "saving Axys Holdings and Transactions data for #{portfolio_name} on #{date}..."
      save_holdings( portfolio_name, date )
      save_transactions( portfolio_name, date )
      puts "done."
    end
    
    def save_holdings( portfolio_name, date )
      rep = Axys::AppraisalWithTickerAndCusipReport.new :portfolio_name => portfolio_name, start: date
      rep.run! remote: true
      output = holdings_output_path( portfolio_name, date )
      FileUtils.mkdir_p File.dirname( output )
      File.open(output, "wb") { |f| f << rep.attribs.to_yaml }
    end

    def save_transactions( portfolio_name, date )
      start_date = date.prev_trading_day+1
      rep = Axys::TransactionsWithSecuritiesReport.new portfolio_name: portfolio_name, start: start_date, end: date
      rep.run! remote: true
      output = transactions_output_path( portfolio_name, date )
      FileUtils.mkdir_p File.dirname( output )
      File.open(output, "wb") { |f| f << rep.attribs.to_yaml }
    end
    
    def holdings_output_path( portfolio_name, date )
      filename = "#{sanitized_name( portfolio_name )}_holdings_#{date.strftime('%m%d%y')}.yaml"
      File.join output_dir_tree( date ), filename
    end
    
    def transactions_output_path( portfolio_name, date )
      filename = "#{sanitized_name( portfolio_name )}_transactions_#{date.strftime('%m%d%y')}.yaml"
      File.join output_dir_tree( date ), filename
    end
    
    def sanitized_name( portfolio_name )
      portfolio_name.downcase.delete "+@&"
    end
    
    def output_dir_tree( date )
      File.join Rails.root, "spec", "data", date.year.to_s, date.month.to_s, date.day.to_s
    end
  end
end