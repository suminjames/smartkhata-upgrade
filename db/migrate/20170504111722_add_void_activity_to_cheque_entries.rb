class AddVoidActivityToChequeEntries < ActiveRecord::Migration
  def change
    add_column :cheque_entries, :void_date, :date
    add_column :cheque_entries, :void_narration,  :text
  end
end
