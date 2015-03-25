class Attribution::DataFile
  FIELDS = {
    cusip: "CUSIP",
    symbol: "SYMBOL"
  }
  
  BKP_DIR = File.join Rails.root, "tmp", "Daily Performance Files"
  
  def initialize( day )
    raise( ArgumentError, "must pass an Attribution::Day" ) unless day.is_a?( Attribution::Day )
    portfolio = day.portfolio
    @aggregator = Attribution::DataAggregator.new :date => day.date, :portfolio => portfolio
  end
  
  def create
    @aggregator.create_reports
    ::CSV.open( output_filepath, "wb" ) do |csv|
      write_header( csv )
      @aggregator.companies.each do |company|
        write_company( csv, company )
      end
    end
    self
  end
  
  def write_company( csv, company )
    perf_keys = Attribution::DataAggregator::TIME_FRAMES.keys.map do |key|
      [:performance, :contribution].map do |desc|
        "#{key.to_s}_#{desc.to_s}".to_sym
      end
    end.flatten
    
    keys = FIELDS.keys + perf_keys
    puts "company is : " + company.inspect
    company_values = keys.map { |k| company[k] }
    csv << company_values
  end
  
  def write_header( csv )
    perf_fields = Attribution::DataAggregator::TIME_FRAMES.values.map do |val|
      ["Performance", "Contribution"].map do |desc|
        "#{val} #{desc}"  
      end
    end.flatten
    values = FIELDS.values + perf_fields
    csv << values
  end

  def output_filepath
    FileUtils.mkdir_p bkp_dir
    File.join bkp_dir, filename
  end
  alias_method :path, :output_filepath
  
  def bkp_dir
    BKP_DIR
  end
  
  def filename
    portfolio_name = @aggregator.portfolio.name.delete "+&@"
    date = @aggregator.date
    "#{portfolio_name} Daily Performance File - #{date.strftime('%-m-%-d-%Y')}.csv"
  end
  
  def path
    File.join bkp_dir, filename
  end
end
