class CreateEmployeeLedgerAssociations < ActiveRecord::Migration
  def change
    create_table :employee_ledger_associations do |t|
      t.references :employee_account, index: true
      t.references :ledger, index:true
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.timestamps null: false
    end
  end
end
