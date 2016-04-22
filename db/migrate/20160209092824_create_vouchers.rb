class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.integer :fy_code
      t.integer :voucher_number
    	t.date :date
    	t.string :date_bs
    	t.string :desc
      t.integer :voucher_type, default: 0
      t.integer :voucher_status, default: 0
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
      t.boolean :is_payment_bank
      t.timestamps null: false
    end
    add_index :vouchers, [:fy_code, :voucher_number, :voucher_type], unique: true
  end
end
