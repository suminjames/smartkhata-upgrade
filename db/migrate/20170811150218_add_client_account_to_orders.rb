class AddClientAccountToOrders < ActiveRecord::Migration
  def change
    add_foreign_key :orders, :client_accounts
  end
end
