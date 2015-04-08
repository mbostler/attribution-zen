module Attribution
  def self.table_name_prefix
    'attribution_'
  end
  
  def self.test
    d0 = Date.civil(2015, 1, 1)
    d1 = Date.civil(2015, 3, 31)
    
    portfolio = Attribution::Portfolio.where( name: "+&smcomp" ).first_or_create
    report = Attribution::Report.new :start_date => d0, :end_date => d1, :portfolio => portfolio
    
    puts "STARTING"
    result = RubyProf.profile do
      report.calculate
      puts "report.cumulative_portfolio_performance is : " + report.cumulative_portfolio_performance.inspect
    end
    
    printer = RubyProf::GraphHtmlPrinter.new( result )
    output_path = File.join Rails.root, "tmp", "profile_output.html"
    File.open( output_path, "wb" ) { |f| printer.print( f, {} ) } 
  end

end
