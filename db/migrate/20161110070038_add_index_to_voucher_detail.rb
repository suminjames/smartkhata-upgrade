class AddIndexToVoucherDetail < ActiveRecord::Migration
  def change
    add_index :voucher_detail, :voucher_code
    add_index :voucher_detail, :voucher_no
  end
end
