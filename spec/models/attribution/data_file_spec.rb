require 'rails_helper'

RSpec.describe Attribution::DataFile, :type => :model do
  it 'should raise error unless passed an Attribution::Day' do
    d = Attribution::Day.new
    expect { Attribution::DataFile.new }.to raise_error
    expect { Attribution::DataFile.new( 5 ) }.to raise_error
    expect { Attribution::DataFile.new( d ) }.to_not raise_error
  end

  describe 'on create' do
    it 'should be able to create a data file, returning path to file' do
      d = Attribution::Day.new
      df = Attribution::DataFile.new( d )
      df.create
      expect( File.exists?( df.path ) ).to eq(true)
    end
    
    it "should create a header" do
      d = Attribution::Day.new
      df = Attribution::DataFile.new( d )
      
      expect( df ).to receive( :create_header )
      df.create
    end
  end
end
