class AddGroupLeaderAndReferrerToClientAccounts < ActiveRecord::Migration
  def change
    add_column :client_accounts, :referrer_name, :string
    add_reference :client_accounts, :group_leader
  end
end
