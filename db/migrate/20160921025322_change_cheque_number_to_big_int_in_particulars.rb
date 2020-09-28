class ChangeChequeNumberToBigIntInParticulars < ActiveRecord::Migration
  def change
    change_column :particulars, :cheque_number, :integer, limit: 8
  end
end
