class CreateChequeEntries < ActiveRecord::Migration
  def change
    create_table :cheque_entries do |t|
      t.integer :cheque_number
      t.references :bank_account
      t.references :particular
      t.timestamps null: false
    end
  end
end
