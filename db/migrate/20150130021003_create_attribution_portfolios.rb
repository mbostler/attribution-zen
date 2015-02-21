class CreateAttributionPortfolios < ActiveRecord::Migration
  def change
    create_table :attribution_portfolios do |t|
      t.string :name, null: false
      t.string :human_name
      t.string :account_number

      t.timestamps null: false
    end
  end
end
