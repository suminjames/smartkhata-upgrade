class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
    	t.string :name
    	t.string :client_code
    	t.decimal :opening_blnc , precision: 15, scale: 4, default: 0.00
    	t.decimal :closing_blnc , precision: 15, scale: 4, default: 0.00
      t.timestamps null: false
      t.references :group,  index: true
      t.references :bank_account,  index: true
      t.references :client_account,  index: true
    end
  end
end
