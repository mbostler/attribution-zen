class CreateAttributionHoldingCodes < ActiveRecord::Migration
  def change
    create_table :attribution_holding_codes do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
