class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
    	t.string :bill_number
    	t.decimal :net_amount , precision: 15, scale: 3, default: 0
    	t.integer :type
    	t.integer :status
      t.timestamps null: false
      t.index :bill_number, unique: true
    end
  end
end
