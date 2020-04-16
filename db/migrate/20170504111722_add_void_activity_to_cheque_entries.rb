class AddVoidActivityToChequeEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :cheque_entries, :void_date, :date
    add_column :cheque_entries, :void_narration,  :text
  end
end
