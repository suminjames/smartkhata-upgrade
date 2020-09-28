class AddUserAccessRoleIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_access_role_id, :integer, index: true
  end
end
