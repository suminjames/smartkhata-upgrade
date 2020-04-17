class CreateBranches < ActiveRecord::Migration[4.2]
  def change
    create_table :branches do |t|
      t.string :code
      t.string :address

      t.timestamps null: false
    end
  end
end
