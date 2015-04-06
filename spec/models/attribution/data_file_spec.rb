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
      portfolio = Attribution::Portfolio.where( name: "ginkgo" ).first_or_create
      d = Attribution::Day.new portfolio_id: portfolio.id, date: Date.today
      df = Attribution::DataFile.new( d )
      allow_any_instance_of( Attribution::DataAggregator ).to receive( :create_reports ).and_return( true )
      df.create
      expect( File.exists?( df.path ) ).to eq(true)
    end
    
    it "should create a header" do
      portfolio = Attribution::Portfolio.where( name: "ginkgo" ).first_or_create
      d = Attribution::Day.new portfolio_id: portfolio.id, date: Date.today
      df = Attribution::DataFile.new( d )
      allow_any_instance_of( Attribution::DataAggregator ).to receive( :create_reports ).and_return( true )
      
      expect( df ).to receive( :write_header )
      df.create
    end
  end
end
