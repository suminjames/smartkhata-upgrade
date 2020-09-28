class AddVoucherDateParsedToVoucher < ActiveRecord::Migration
  def change
    add_column :voucher, :voucher_date_parsed, :date
  end
end
