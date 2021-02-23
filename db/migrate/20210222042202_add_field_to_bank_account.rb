class AddFieldToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :default_for_esewa_receipt, :boolean
    add_column :bank_accounts, :default_for_nchl_receipt, :boolean
  end
end
