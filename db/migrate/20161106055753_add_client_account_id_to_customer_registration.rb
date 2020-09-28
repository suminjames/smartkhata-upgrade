class AddClientAccountIdToCustomerRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column :customer_registration, :client_account_id, :integer
  end
end
