class AddFyCodeToChequeEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :cheque_entries, :fy_code, :integer, index: true
  end
end
