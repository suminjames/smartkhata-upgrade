class AddAccessLevelToUserAccessRoles < ActiveRecord::Migration
  def change
    add_column :user_access_roles, :access_level, :integer, default: 0
  end
end
