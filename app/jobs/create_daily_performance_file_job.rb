class CreateDailyPerformanceFileJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    File.open( output_filepath, "wb") { |f| }
  end
  
  def output_filepath
    FileUtils.mkdir_p bkp_dir
    File.join bkp_dir, filename
  end
  
  def bkp_dir
    File.join Rails.root, "tmp", "Daily Performance Files"
  end
  
  def filename
    "Daily Performance File.csv"
  end
end
