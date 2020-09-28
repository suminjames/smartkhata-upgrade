class AddIndexToVoucher < ActiveRecord::Migration[4.2]
  def change
    add_index :voucher, :voucher_code
    add_index :voucher, :voucher_no
  end
end
