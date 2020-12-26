class CreateInterestParticulars < ActiveRecord::Migration
  def change
    create_table :interest_particulars do |t|
      t.decimal :amount, :precision => 12, :scale => 2, default: 0.0
      t.decimal :interest, :precision => 12, :scale => 2, default: 0.0
      t.integer :rate
      t.date :date
      t.integer :interest_type
      t.string :date_bs
      t.references :ledger, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
