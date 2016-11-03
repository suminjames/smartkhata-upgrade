class CreateVoucherParticulars < ActiveRecord::Migration
  def change
    create_table :voucher_particulars do |t|
      t.string :bill_no
      t.string :count_shares
      t.integer :no_of_shares
      t.decimal :rate_per_share, precision: 15, scale: 2
      t.string :company_code
      t.string :commission_rate
      t.string :fiscal_year
      t.string :transaction_fee
    end
  end
end
