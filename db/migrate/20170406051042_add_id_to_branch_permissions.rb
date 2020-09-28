class AddIdToBranchPermissions < ActiveRecord::Migration[4.2]
  def change
    add_column :branch_permissions, :id, :primary_key
  end
end
