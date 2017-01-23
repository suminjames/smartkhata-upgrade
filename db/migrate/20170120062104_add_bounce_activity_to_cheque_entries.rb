class AddBounceActivityToChequeEntries < ActiveRecord::Migration
  def change
    add_column :cheque_entries, :bounce_date, :date
    add_column :cheque_entries, :bounce_narration,  :text
  end
end
