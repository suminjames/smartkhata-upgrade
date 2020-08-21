class CreateInterestParticulars < ActiveRecord::Migration
  def change
    create_table :interest_particulars do |t|
      t.integer :amount
      t.integer :rate
      t.date :date
      t.integer :interest_type
      t.references :ledger, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
