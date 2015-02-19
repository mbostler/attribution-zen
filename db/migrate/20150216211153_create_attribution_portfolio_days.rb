class CreateAttributionPortfolioDays < ActiveRecord::Migration
  def change
    create_table :attribution_portfolio_days do |t|
      t.integer :day_id
      t.float :performance

      t.timestamps null: false
    end
  end
end
