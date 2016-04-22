class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.integer :account_number
      t.string :bank_name
      t.boolean :default_for_purchase
      t.boolean :default_for_sales
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.timestamps null: false
      t.references :bank , index: true
    end
  end
end
