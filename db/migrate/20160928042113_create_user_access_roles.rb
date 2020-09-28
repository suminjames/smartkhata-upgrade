class CreateUserAccessRoles < ActiveRecord::Migration
  def change
    create_table :user_access_roles do |t|
      t.integer :role_type, default: 0
      t.string :role_name
      t.text :description
      t.timestamps null: false
    end
  end
end
