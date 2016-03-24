class CreateParticulars < ActiveRecord::Migration
  def change
    create_table :particulars do |t|
    	t.decimal :opening_blnc , precision: 15, scale: 4, default: 0
    	t.integer :transaction_type
      t.integer :cheque_number
      t.string :name
      t.string :description
    	t.decimal :amnt , precision: 15, scale: 4, default: 0
    	t.decimal :running_blnc , precision: 15, scale: 4, default: 0
      t.integer :additional_bank_id
      t.timestamps null: false
      t.references :ledger,  index: true
      t.references :voucher,  index: true
    end
  end
end
