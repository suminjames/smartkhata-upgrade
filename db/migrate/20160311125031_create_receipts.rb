class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :name
      t.decimal :amount , precision: 15, scale: 2, default: 0.00
      t.string :date_bs
      t.string :description
      t.integer :receipt_type
      t.integer :cheque_entry_id
      t.references :voucher
      t.timestamps null: false
    end
  end
end
