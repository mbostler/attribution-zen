class CreateAttributionTransactions < ActiveRecord::Migration
  def change
    create_table :attribution_transactions do |t|
      t.string :code
      t.string :security
      t.integer :quantity
      t.date :trade_date
      t.date :settle_date
      t.string :sd_type
      t.string :sd_symbol
      t.float :trade_amount
      t.string :cusip
      t.string :symbol
      t.integer :day_id
      t.integer :company_id
      t.string :close_method
      t.string :lot

      t.timestamps null: false
    end
  end
end
