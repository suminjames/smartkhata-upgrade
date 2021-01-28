class AddIndexColumnsToInterestParticular < ActiveRecord::Migration[4.2]
  def change
    add_index :interest_particulars, [:ledger_id, :date], unique: true
    add_index :interest_particulars, :date
  end
end
