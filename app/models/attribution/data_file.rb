class Attribution::DataFile
  FIELDS = {
    :cusip => "CUSIP",
    :ticker => "TICKER"
  }
  def initialize( day )
    raise( ArgumentError, "must pass an Attribution::Day" ) unless day.is_a?( Attribution::Day )
  end
  
  def create
    ::CSV.open( output_filepath, "wb" ) do |csv|
      create_header( csv )
    end
    self
  end
  
  def create_header( csv )
    csv << FIELDS.values
  end

  def output_filepath
    FileUtils.mkdir_p bkp_dir
    File.join bkp_dir, filename
  end
  alias_method :path, :output_filepath
  
  def bkp_dir
    File.join Rails.root, "tmp", "Daily Performance Files"
  end
  
  def filename
    "Daily Performance File.csv"
  end
end
