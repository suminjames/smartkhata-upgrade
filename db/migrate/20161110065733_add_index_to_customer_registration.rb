class AddIndexToCustomerRegistration < ActiveRecord::Migration
  def change
    add_index :customer_registration, :customer_code
    add_index :customer_registration, :ac_code
  end
end
