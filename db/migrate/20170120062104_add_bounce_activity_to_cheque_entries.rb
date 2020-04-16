class AddBounceActivityToChequeEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :cheque_entries, :bounce_date, :date
    add_column :cheque_entries, :bounce_narration,  :text
  end
end
