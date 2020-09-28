class CreateSettlements < ActiveRecord::Migration[4.2]
  def change
    create_table :settlements do |t|
      t.string :name
      t.decimal :amount
      t.string :date_bs
      t.string :description
      t.integer :settlement_type
      t.integer :fy_code, index: true
      t.integer :settlement_number, index: true
      t.integer :client_account_id, index: true
      t.integer :vendor_account_id, index: true
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.string :receiver_name
      t.references :voucher, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
