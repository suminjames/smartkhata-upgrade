class ChangeChequeNumberToBigIntInParticulars < ActiveRecord::Migration[4.2]
  def change
    change_column :particulars, :cheque_number, :integer, limit: 8
  end
end
