class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :dp_id
      t.string :full_name
      t.string :phone_number
      t.string :address
      t.string :pan_number
      t.string :fax_number
      t.string :broker_code
      t.timestamps null: false
    end
  end
end
