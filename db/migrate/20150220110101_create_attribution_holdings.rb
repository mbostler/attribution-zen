class CreateAttributionHoldings < ActiveRecord::Migration
  def change
    create_table :attribution_holdings do |t|
      t.float :quantity
      t.string :ticker
      t.string :cusip
      t.string :security
      t.float :unit_cost
      t.float :total_cost
      t.float :price
      t.float :market_value
      t.float :pct_assets
      t.float :yield
      t.integer :company_id
      t.string :code
      t.integer :type_id
      t.integer :day_id

      t.timestamps null: false
    end
  end
end
