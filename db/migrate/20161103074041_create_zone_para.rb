class CreateZonePara < ActiveRecord::Migration[4.2]
  def change
    create_table :zone_para do |t|
      t.string :regional_code
      t.string :zone_code
      t.string :zone_name
    end
  end
end
