class CreateVoucherTransaction < ActiveRecord::Migration[4.2]
  def change
    create_table :voucher_transaction do |t|
      t.string :voucher_no
      t.string :voucher_code
      t.string :fiscal_year
    end
  end
end
