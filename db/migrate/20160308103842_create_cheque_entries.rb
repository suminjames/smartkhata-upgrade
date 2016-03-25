class CreateChequeEntries < ActiveRecord::Migration
  def change
    create_table :cheque_entries do |t|
      t.integer :cheque_number
      t.integer :additional_bank_id
      t.references :bank_account, index: true
      t.references :particular, index: true
      t.references :settlement, index: true
      t.timestamps null: false
    end
  end
end
