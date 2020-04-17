class CreateBankAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_accounts do |t|
      t.string :account_number
      t.string :bank_name
      t.boolean :default_for_payment
      t.boolean :default_for_receipt
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.timestamps null: false
      t.references :bank , index: true
    end
  end
end
