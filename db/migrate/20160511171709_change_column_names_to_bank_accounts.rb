class ChangeColumnNamesToBankAccounts < ActiveRecord::Migration
  def change
    rename_column :bank_accounts, :default_for_purchase, :default_for_payment
    rename_column :bank_accounts, :default_for_sales, :default_for_receive
  end
end
