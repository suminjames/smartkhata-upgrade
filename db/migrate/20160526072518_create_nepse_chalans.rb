class CreateNepseChalans < ActiveRecord::Migration[4.2]
  def change
    create_table :nepse_chalans do |t|
      t.decimal :chalan_amount, precision: 15, scale: 4, default: 0
      t.integer :transaction_type
      t.string :deposited_date_bs
      t.date :deposited_date
      t.string :nepse_settlement_id
      t.references :voucher, index: true, foreign_key: true
      t.timestamps null: false
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
    end
  end
end
