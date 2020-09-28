class CreateDistrictPara < ActiveRecord::Migration[4.2]
  def change
    create_table :district_para do |t|
      t.string :zone_code
      t.string :district_code
      t.string :district_name
    end
  end
end
