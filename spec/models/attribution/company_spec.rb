# == Schema Information
#
# Table name: attribution_companies
#
#  id           :integer          not null, primary key
#  name         :string
#  cusip        :string
#  ticker       :string
#  code_id      :integer
#  effective_on :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::Company, :type => :model do
  describe "#tag method" do
    it "should return code name if no ticker" do
      hc = Attribution::HoldingCode.create( :name => "asdf" )
      c = Attribution::Company.create code_id: hc.id
      expect( c.tag ).to eq("asdf")
    end
  end
end
