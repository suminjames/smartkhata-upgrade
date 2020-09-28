class AddIdToBranchPermissions < ActiveRecord::Migration
  def change
    add_column :branch_permissions, :id, :primary_key
  end
end
