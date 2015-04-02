# == Schema Information
#
# Table name: attribution_security_days
#
#  id           :integer          not null, primary key
#  weight       :float
#  performance  :float
#  contribution :float
#  company_id   :integer
#  day_id       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Attribution::SecurityDay < ActiveRecord::Base
  belongs_to :company, class_name: "Attribution::Company"
  belongs_to :day, :class_name => "Attribution::Day"
  belongs_to :code, :class_name => "Attribution::HoldingCode"
  
  before_save :link_security_data

  def link_security_data
    return if !!self.company_id
    if self.company and self.company.cusip == self.cusip
      return
    else
      c = Attribution::Company.
              where( :cusip => cusip ).
              first_or_create
      self.company = c
    end
  end
  
  def date
    self.day and self.day.date
  end
  
  def ticker
    self.company.ticker
  end
  
  def tag
    self.company.tag
  end
  
  def cash_item?
    cusip.nil?
  end
  
  def cash_type?
    holdings.any? { |h| h.cash_type? }
  end
  
  def intacc?
    holdings.any? { |h| h.intacc? }
  end
  
  def audit
    puts "Auditing #{company.tag} on #{day.date}"
    puts "======================================"
    puts self.inspect
    puts "holdings is : " + holdings.inspect
    puts "prev_holdings is : " + prev_holdings.inspect
    puts "transactions is : " + transactions.inspect
    
    Attribution::PerformanceCalculator.audit( holdings: holdings, 
                                              prev_holdings: prev_holdings, 
                                              transactions: transactions,
                                              treat_as_cash: cash_type?,
                                              treat_as_intacc: intacc? )
  end
  
  def holdings
    day.holdings.where( company_id: company_id )
  end

  def prev_holdings
    day.prev_holdings.where( company_id: company_id )
  end
  
  def transactions
    day.transactions.where( company_id: company_id )
  end
end
