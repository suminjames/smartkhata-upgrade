class AddIndexToVoucher < ActiveRecord::Migration
  def change
    add_index :voucher, :voucher_code
    add_index :voucher, :voucher_no
  end
end
