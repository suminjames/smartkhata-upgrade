class AddUsernameToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :pass_changed, :boolean, default: false
    change_column_null :users, :email, true
    add_index :users, :username, unique: true
  end
end