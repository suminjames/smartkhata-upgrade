class AddUserAccessRoleIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :user_access_role_id, :integer, index: true
  end
end
