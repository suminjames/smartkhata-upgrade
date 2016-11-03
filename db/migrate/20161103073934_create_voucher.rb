class CreateVoucher < ActiveRecord::Migration
  def change
    create_table :voucher do |t|
      t.string :voucher_no
      t.string :voucher_code
      t.string :serial_no
      t.string :voucher_date
      t.string :bs_date
      t.string :dr_ac_code
      t.string :dr_sub_code
      t.string :cr_ac_code
      t.string :cr_sub_code
      t.string :narration
      t.string :paid_to_received_from
      t.string :cheque_no
      t.string :prepared_by
      t.string :checked_by
      t.string :approved_by
      t.string :authorized_by
      t.integer :transaction_no, limit: 8
      t.string :fiscal_year
      t.string :bill_no
      t.string :posted_by
    end
  end
end
