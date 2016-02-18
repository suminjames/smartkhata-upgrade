class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
    	t.string :name
    	t.decimal :opening_blnc , precision: 10, scale: 3, default: 0.00
    	t.decimal :closing_blnc , precision: 10, scale: 3, default: 0.00
      t.timestamps null: false
      t.references :group
    end
  end
end
