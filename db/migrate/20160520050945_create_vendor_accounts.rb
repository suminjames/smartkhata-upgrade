class CreateVendorAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :vendor_accounts do |t|
      t.string :name
      t.string :address
      t.string :phone_number

      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :branch_id, index: true
      t.timestamps null: false
    end
  end
end
