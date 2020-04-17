class CreateVoucherParticulars < ActiveRecord::Migration[4.2]
  def change
    create_table :voucher_particulars do |t|
      t.string :bill_no
      t.string :count_shares
      t.string :no_of_shares
      t.string :rate_per_share
      t.string :company_code
      t.string :commission_rate
      t.string :fiscal_year
      t.string :transaction_fee
    end
  end
end
