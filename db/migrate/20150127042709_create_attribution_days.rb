class CreateAttributionDays < ActiveRecord::Migration
  def change
    create_table :attribution_days do |t|
      t.date :date

      t.timestamps null: false
    end
  end
end
