class CreateVoucherUser < ActiveRecord::Migration
  def change
    create_table :voucher_user do |t|
      t.string :voucher_code
      t.string :voucher_name
      t.string :voucher_type
      t.string :user_code
      t.string :status
    end
  end
end
