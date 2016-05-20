class CreateChequeEntries < ActiveRecord::Migration
  def change
    create_table :cheque_entries do |t|
      t.string    :beneficiary_name
      t.integer   :cheque_number
      t.integer   :additional_bank_id
      t.integer   :status, :default => 0
      t.integer   :cheque_issued_type, default: 0
      t.date      :cheque_date
      t.decimal   :amount , precision: 15, scale: 4, default: 0.00

      t.references :bank_account, index: true
      t.references :client_account, index:true
      t.references :vendor_account, index:true
      t.references :settlement, index: true
      t.references :voucher, index: true
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :branch_id, index: true
      t.timestamps null: false
    end
  end
end
