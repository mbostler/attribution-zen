class CreateAttributionSecurities < ActiveRecord::Migration
  def change
    create_table :attribution_securities do |t|
      t.string :cusip
      t.string :ticker
      t.date :effective_on

      t.timestamps null: false
    end
  end
end
