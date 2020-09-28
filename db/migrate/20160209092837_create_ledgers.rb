class CreateLedgers < ActiveRecord::Migration[4.2]
  def change
    create_table :ledgers do |t|
    	t.string :name
    	t.string :client_code
    	t.decimal :opening_blnc , precision: 15, scale: 4, default: 0.00
    	t.decimal :closing_blnc , precision: 15, scale: 4, default: 0.00
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :fy_code, index: true
      t.integer :branch_id, index: true
      t.decimal :dr_amount,  :precision => 15, :scale => 4, :default => 0.00, null: false
      t.decimal :cr_amount,  :precision => 15, :scale => 4, :default => 0.00, null: false

      t.timestamps null: false
      t.references :group,  index: true
      t.references :bank_account,  index: true
      t.references :client_account,  index: true
      t.references :employee_account, index: true
      t.references :vendor_account, index: true
    end
  end
end
