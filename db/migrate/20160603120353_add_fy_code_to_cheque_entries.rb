class AddFyCodeToChequeEntries < ActiveRecord::Migration
  def change
    add_column :cheque_entries, :fy_code, :integer, index: true
  end
end
