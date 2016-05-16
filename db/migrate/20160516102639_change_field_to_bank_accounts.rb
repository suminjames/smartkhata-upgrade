class ChangeFieldToBankAccounts < ActiveRecord::Migration
  def change
    change_column :bank_accounts, :account_number, :string
  end
end
