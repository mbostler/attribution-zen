class CreateAttributionCompanies < ActiveRecord::Migration
  def change
    create_table :attribution_companies do |t|
      t.string :name
      t.string :cusip
      t.string :ticker
      t.date :effective_on

      t.timestamps null: false
    end
  end
end
