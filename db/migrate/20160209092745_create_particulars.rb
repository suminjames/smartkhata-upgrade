class CreateParticulars < ActiveRecord::Migration
  def change
    create_table :particulars do |t|
    	t.decimal :opening_blnc , precision: 15, scale: 2, default: 0
    	t.integer :transaction_type
      t.integer :cheque_number
      t.string :name
      t.string :description
    	t.decimal :amnt , precision: 15, scale: 2, default: 0
    	t.decimal :running_blnc , precision: 15, scale: 2, default: 0
      t.timestamps null: false
      t.references :ledger
      t.references :voucher
      t.references :bill
    end
  end
end
