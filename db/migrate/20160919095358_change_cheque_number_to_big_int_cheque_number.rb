class ChangeChequeNumberToBigIntChequeNumber < ActiveRecord::Migration[4.2]
  def change
    change_column :cheque_entries, :cheque_number, :integer, limit: 8
  end
end
