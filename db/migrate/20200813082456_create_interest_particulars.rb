class CreateInterestParticulars < ActiveRecord::Migration
  def change
    create_table :interest_particulars do |t|
      t.string :amount
      t.integer :rate
      t.date :date
      t.string :interest_type
      t.references :ledger, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
