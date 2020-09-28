class ChangeColumnNameToMenuPermission < ActiveRecord::Migration[4.2]
  def change
    rename_column :menu_permissions, :user_id, :user_access_role_id
  end
end
