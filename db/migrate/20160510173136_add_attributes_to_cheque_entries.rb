class AddAttributesToChequeEntries < ActiveRecord::Migration
  def change
    add_column :cheque_entries, :status, :integer, :default => 0
    add_column :cheque_entries, :cheque_date, :date
  end
end
