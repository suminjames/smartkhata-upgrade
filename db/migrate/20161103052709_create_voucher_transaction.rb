class CreateVoucherTransaction < ActiveRecord::Migration
  def change
    create_table :voucher_transaction do |t|
      t.string :voucher_no
      t.string :voucher_code
      t.string :fiscal_year
    end
  end
end
