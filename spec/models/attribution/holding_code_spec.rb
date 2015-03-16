# == Schema Information
#
# Table name: attribution_holding_codes
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Attribution::HoldingCode, :type => :model do
  it 'knows whether or not it is usable' do
    excluded_types = %w(acctfeepay adminfeepay custfeepay manfeepay ticketfeepay)
    excluded_types.each do |ex_type|
      hc = Attribution::HoldingCode.new :name => ex_type
      expect( hc.usable? ).to eq(false)
    end

    included_types = %w(divacc intacc cash redpay legalfeepay)
    included_types.each do |in_type|
      hc = Attribution::HoldingCode.new :name => in_type
      expect( hc.usable? ).to eq(true)
    end
  end
end
