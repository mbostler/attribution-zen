class CreateAttributionTransactions < ActiveRecord::Migration
  def change
    create_table :attribution_transactions do |t|
      t.string :code
      t.string :security
      t.date :trade_date
      t.date :settle_date
      t.string :sd_type
      t.string :sd_symbol
      t.float :trade_amount
      t.string :cusip
      t.string :symbol
      t.integer :day_id

      t.timestamps null: false
    end
  end
end
