class Axys::TransactionsWithSecuritiesReport
  def self.run!(opts)
    new(opts).run! :remote => true
  end
end

class Axys::AppraisalWithTickerAndCusipReport
  def self.run!(opts)
    new(opts).run! :remote => true
  end
end

module Attribution
  def self.table_name_prefix
    'attribution_'
  end

end
