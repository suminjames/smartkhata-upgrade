class CreateBranchPermissions < ActiveRecord::Migration
  def change
    create_table :branch_permissions, id:false do |t|
      t.integer :branch_id
      t.integer :user_id
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps null: false
    end
  end
end
