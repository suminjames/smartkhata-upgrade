class CreateCloseouts < ActiveRecord::Migration
  def change
    create_table :closeouts do |t|
      t.decimal :settlement_id, precision: 18, scale: 0
      t.decimal :contract_number, precision: 18, scale: 0
      t.integer :seller_cm
      t.string :seller_client
      t.integer :buyer_cm
      t.string :buyer_client
      t.string :isin
      t.string :scrip_name
      t.integer :quantity
      t.integer :shortage_quantity
      t.decimal :rate, precision: 15, scale: 4, default:0
      t.decimal :net_amount, precision: 15, scale: 4, default: 0
      t.integer :closeout_type
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :branch_id, index: true
      t.timestamps null: false
    end
  end
end
