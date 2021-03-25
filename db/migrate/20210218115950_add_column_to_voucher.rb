class AddColumnToVoucher < ActiveRecord::Migration[4.2]
  def change
    add_reference :vouchers, :receipt_transaction, index: true, foreign_key: true
  end
end
