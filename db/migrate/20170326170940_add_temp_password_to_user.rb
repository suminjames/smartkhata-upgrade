class AddTempPasswordToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :temp_password, :string
  end
end
