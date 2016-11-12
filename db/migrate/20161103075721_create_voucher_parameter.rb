class CreateVoucherParameter < ActiveRecord::Migration
  def change
    create_table :voucher_parameter do |t|
      t.string :voucher_code
      t.string :voucher_name
      t.string :voucher_type
      t.string :dr_ac_code
      t.string :dr_sub_code
      t.string :cr_ac_code
      t.string :cr_sub_code
      t.string :check_dr_code
      t.string :check_cr_code
      t.string :checked_by
      t.string :approved_by
      t.string :authorized_by
      t.string :voucher_no_code
    end
  end
end
