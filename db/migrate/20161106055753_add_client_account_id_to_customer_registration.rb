class AddClientAccountIdToCustomerRegistration < ActiveRecord::Migration
  def change
    add_column :customer_registration, :client_account_id, :integer
  end
end
