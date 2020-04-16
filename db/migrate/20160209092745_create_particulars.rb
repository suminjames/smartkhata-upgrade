
class CreateParticulars < ActiveRecord::Migration[4.2]
  def change
    create_table :particulars do |t|
    	t.decimal :opening_blnc , precision: 15, scale: 4, default: 0
    	t.integer :transaction_type
      t.integer :ledger_type, default: 0
      t.integer :cheque_number
      t.string :name
      t.string :description
    	t.decimal :amount , precision: 15, scale: 4, default: 0
    	t.decimal :running_blnc , precision: 15, scale: 4, default: 0
      t.integer :additional_bank_id
      t.integer :particular_status, default: 1
      t.string :date_bs
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
      t.date :transaction_date
      t.timestamps null: false
      t.references :ledger,  index: true
      t.references :voucher,  index: true
    end
  end
end
