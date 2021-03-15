class AddColumnToVoucher < ActiveRecord::Migration
  def change
    add_reference :vouchers, :receipt_transaction, index: true, foreign_key: true
  end
end
