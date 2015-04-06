# module Axys
  class Axys::TransactionsWithSecuritiesReport #< Axys::Report
    def self.run!(opts)
      new(opts).run! :remote => true
    end

    if $RUN_AXYS_LOCALLY
      puts "RUNNING AXYS LOCALLY"
      def run!(opts={})
        txns = []
        self.attribs = (self.start..self.end).inject({}) do |attribs_to_load, date|
          if date.trading_day?
            txns_file = AxysDataStore.transactions_output_path( portfolio_name, date )
            raise "couldn't find transactions file at #{txns_file}" unless File.exists?(txns_file)
            attrbs = YAML.load File.read( txns_file )
            txns += attrbs[:transactions]
            attribs_to_load = attrbs
          else # THIS IS A FIX THAT ENABLES TESTS TO RUN WITHOUT ANY DATA FOR WEEKENDS!
            attribs_to_load
          end
        end
        self.attribs[:transactions] = txns
        self.attribs
      end
    end
  end

  class Axys::AppraisalWithTickerAndCusipReport #< Axys::Report
    def self.run!(opts)
      new(opts).run! :remote => true
    end

    if $RUN_AXYS_LOCALLY
      puts "RUNNING AXYS LOCALLY"
      def run!(opts={})
        holdings_file = AxysDataStore.holdings_output_path( portfolio_name, self.start )
        raise "couldn't find holdings file at #{holdings_file}" unless File.exists?(holdings_file)
        self.attribs = YAML.load File.read( holdings_file )
      end
    end
  end
# end
