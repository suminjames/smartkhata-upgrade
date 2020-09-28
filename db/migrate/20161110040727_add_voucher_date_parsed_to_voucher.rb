class AddVoucherDateParsedToVoucher < ActiveRecord::Migration[4.2]
  def change
    add_column :voucher, :voucher_date_parsed, :date
  end
end
