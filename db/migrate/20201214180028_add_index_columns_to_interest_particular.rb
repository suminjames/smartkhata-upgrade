class AddIndexColumnsToInterestParticular < ActiveRecord::Migration
  def change
    add_index :interest_particulars, [:ledger_id, :date], unique: true
  end
end
