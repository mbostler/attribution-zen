# == Schema Information
#
# Table name: attribution_holding_codes
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attribution::HoldingCode < ActiveRecord::Base
  CODES = {
    "acctfeepay" => false,
    "custfeepay" => false,
    "legalfeepay" => true,
    "manfeepay" => false,
    "redpay" => true,
    "ticketfeepay" => false,
    "adminfeepay" => false,
    "divacc" => true,
    "intacc" => true,
    "cash" => true,
    
  }
  
  has_many :holdings, class_name: "Attribution::Holding"
  has_many :companies, class_name: "Attribution::Company"
  
  def self.usable_code?( code )
    code_usability = CODES[code]
    raise "don't know how to test usability for holding code #{code}" if code_usability.nil?
    code_usability
  end
  
  def usable?
    Attribution::HoldingCode.usable_code?( self.name )
  end
end
