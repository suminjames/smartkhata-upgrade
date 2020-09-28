class CreateZonePara < ActiveRecord::Migration
  def change
    create_table :zone_para do |t|
      t.string :regional_code
      t.string :zone_code
      t.string :zone_name
    end
  end
end
