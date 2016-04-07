class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
    	t.integer :bill_number
      t.string :client_name
    	t.decimal :net_amount , precision: 15, scale: 4, default: 0
      t.decimal :balance_to_pay, precision: 15, scale: 4, default: 0
    	t.integer :bill_type
    	t.integer :status , default: 0
      t.boolean :has_deal_cancelled , default: false
      t.timestamps null: false
      t.integer :fy_code
      t.references :client_account,  index: true
      # t.index :bill_number
    end

    add_index :bills, [:fy_code, :bill_number], unique: true

    create_table :bills_vouchers, id: false do |t|
      t.references :bill, index: true
      t.references :voucher, index: true
    end
  end
end
