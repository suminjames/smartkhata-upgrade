class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :path
      t.boolean :hide_on_main_navigation, default: false
      t.integer :parent_id
      t.string :code

      t.timestamps null: false
    end
  end
end