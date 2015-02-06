# == Schema Information
#
# Table name: attribution_days
#
#  id         :integer          not null, primary key
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Attribution
  class Day < ActiveRecord::Base
    belongs_to :portfolio, :class_name => "Attribution::Portfolio"
    has_one :prev_day, -> { where( :date => self.date-1) }, :class_name => "Attribution::Day"
    has_one :next_day, -> { where( :date => self.date+1) }, :class_name => "Attribution::Day"
  
    def create_data_file
      df = Attribution::DataFile.new( self ).create
    end
  
    def prev_day
      Attribution::Day.where(:date => self.date-1).first_or_create
    end
  
    def next_day
      Attribution::Day.where(:date => self.date+1).first_or_create
    end
    
    def securities
      []
    end
  
  end
end