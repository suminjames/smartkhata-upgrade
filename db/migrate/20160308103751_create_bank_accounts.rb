class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.integer :account_number
      t.string :address
      t.integer :contact_number
      t.boolean :default_for_purchase
      t.boolean :default_for_sales
      t.timestamps null: false
    end
  end
end
