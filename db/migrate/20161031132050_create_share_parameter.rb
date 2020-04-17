class CreateShareParameter < ActiveRecord::Migration[4.2]
  def change
    create_table :share_parameter do |t|
      t.string :share_code
      t.string :share_description
    end
  end
end
