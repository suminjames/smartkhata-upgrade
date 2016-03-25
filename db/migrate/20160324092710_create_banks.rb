class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :name
      t.string :bank_code
      t.string :address
      t.string :contact_no

      t.timestamps null: false
    end
  end
end
