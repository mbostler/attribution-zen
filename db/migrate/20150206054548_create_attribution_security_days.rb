class CreateAttributionSecurityDays < ActiveRecord::Migration
  def change
    create_table :attribution_security_days do |t|
      t.string :cusip
      t.float :weight
      t.float :performance
      t.float :contribution
      t.integer :company_id
      t.integer :day_id
      t.integer :portfolio_id
      t.integer :code_id

      t.timestamps null: false
    end
  end
end
