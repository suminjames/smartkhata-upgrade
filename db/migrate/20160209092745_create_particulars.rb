class CreateParticulars < ActiveRecord::Migration
  def change
    create_table :particulars do |t|
    	t.decimal :opening_blnc , precision: 10, scale: 3, default: 0
    	t.string :trn_type 
      t.string :description
    	t.decimal :amnt , precision: 10, scale: 3, default: 0
    	t.decimal :running_blnc , precision: 10, scale: 3, default: 0
      t.timestamps null: false
      t.references :ledger
      t.references :voucher
    end
  end
end
