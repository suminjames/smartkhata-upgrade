class ChangeColumnNameToMenuPermission < ActiveRecord::Migration
  def change
    rename_column :menu_permissions, :user_id, :user_access_role_id
  end
end
