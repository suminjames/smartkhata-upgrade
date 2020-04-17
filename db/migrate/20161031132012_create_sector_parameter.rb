class CreateSectorParameter < ActiveRecord::Migration[4.2]
  def change
    create_table :sector_parameter do |t|
      t.string :sector_code
      t.string :sector_name
    end
  end
end
