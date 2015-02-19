# == Schema Information
#
# Table name: attribution_days
#
#  id           :integer          not null, primary key
#  date         :date
#  portfolio_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

module Attribution
  class Day < ActiveRecord::Base
    belongs_to :portfolio, :class_name => "Attribution::Portfolio"
    has_many :security_days, :class_name => "Attribution::SecurityDay"
    has_one :portfolio_day, :class_name => "Attribution::PortfolioDay"
    has_one :prev_day, -> { where( :date => self.date-1) }, :class_name => "Attribution::Day"
    has_one :next_day, -> { where( :date => self.date+1) }, :class_name => "Attribution::Day"
  
    def create_data_file
      df = Attribution::DataFile.new( self ).create
    end
  
    def prev_day
      Attribution::Day.where(:date => self.date-1, :portfolio_id => self.portfolio_id).first_or_create
    end
  
    def next_day
      Attribution::Day.where(:date => self.date+1, :portfolio_id => self.portfolio_id).first_or_create
    end
    
  end
end
