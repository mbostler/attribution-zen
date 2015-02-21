class CreateAttributionTransactionTypes < ActiveRecord::Migration
  def change
    create_table :attribution_transaction_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
