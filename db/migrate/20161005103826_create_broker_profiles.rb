class CreateBrokerProfiles < ActiveRecord::Migration
  def change
    create_table :broker_profiles do |t|
      t.string :broker_name
      t.string :broker_number
      t.string :address
      t.integer :dp_code
      t.string :phone_number
      t.string :fax_number
      t.string :email
      t.string :pan_number
      t.integer :profile_type
      t.integer :locale

      t.timestamps null: false
    end
    add_index :broker_profiles, :profile_type
  end
end
