class AddAccessLevelToUserAccessRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :user_access_roles, :access_level, :integer, default: 0
  end
end
