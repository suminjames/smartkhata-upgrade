class CreateMenuItems < ActiveRecord::Migration[4.2]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :path
      t.boolean :hide_on_main_navigation, default: false
      t.integer :request_type, default: 0
      # t.integer :parent_id
      t.string :code
      t.string :ancestry, index: true

      t.timestamps null: false
    end
  end
end
