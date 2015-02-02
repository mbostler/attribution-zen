require 'rails_helper'

RSpec.describe CreateDailyPerformanceFileJob, :type => :job do
  it 'should create an output file' do
    j = CreateDailyPerformanceFileJob.new
    output_filepath = j.output_filepath
    
    FileUtils.rm(output_filepath) if File.exist?(output_filepath)
    expect( File.exists?(output_filepath) ).to eq( false )
    
    j.perform
    expect( File.exists?(output_filepath) ).to eq( true )
  end
end
