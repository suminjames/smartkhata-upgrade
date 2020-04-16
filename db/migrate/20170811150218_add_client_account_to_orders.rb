class AddClientAccountToOrders < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :orders, :client_accounts
  end
end
