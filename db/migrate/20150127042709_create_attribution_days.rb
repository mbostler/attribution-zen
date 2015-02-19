class CreateAttributionDays < ActiveRecord::Migration
  def change
    create_table :attribution_days do |t|
      t.date :date
      t.integer :portfolio_id

      t.timestamps null: false
    end
  end
end
