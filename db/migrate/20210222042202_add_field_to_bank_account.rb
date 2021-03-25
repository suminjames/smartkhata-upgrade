class AddFieldToBankAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :default_for_esewa_receipt, :boolean
    add_column :bank_accounts, :default_for_nchl_receipt, :boolean
  end
end
