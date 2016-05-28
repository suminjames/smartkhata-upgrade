class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
    	t.integer :bill_number
      t.string :client_name
    	t.decimal :net_amount , precision: 15, scale: 4, default: 0
      t.decimal :balance_to_pay, precision: 15, scale: 4, default: 0
    	t.integer :bill_type
    	t.integer :status , default: 0
      t.integer :special_case, default: 0
      t.integer :settlement_approval_status, default: 0
      t.timestamps null: false
      t.integer :fy_code, index: true
      t.date :date, index: true
      t.string :date_bs
      t.date :settlement_date
      t.references :client_account,  index: true
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
    end
    add_index :bills, [:fy_code, :bill_number], unique: true
  end
end
