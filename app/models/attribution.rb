module Attribution
  def self.table_name_prefix
    'attribution_'
  end
  
  def self.test
    day = Attribution::Day.where( :date => Date.yesterday ).first_or_create
    data_file = Attribution::DataFile.new( day )
    data_file.create
  end

end
