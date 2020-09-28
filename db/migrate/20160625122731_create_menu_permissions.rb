class CreateMenuPermissions < ActiveRecord::Migration
  def change
    create_table :menu_permissions do |t|
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.references :menu_item, index: true, foreign_key: true
      t.references :user, index: true
      t.timestamps null: false
    end
  end
end
