class CreateAttributionHoldingTypes < ActiveRecord::Migration
  def change
    create_table :attribution_holding_types do |t|
      t.string :name, null: false   

      t.timestamps null: false
    end
  end
end
