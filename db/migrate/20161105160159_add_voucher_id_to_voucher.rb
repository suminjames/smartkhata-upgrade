class AddVoucherIdToVoucher < ActiveRecord::Migration[4.2]
  def change
    add_column :voucher, :voucher_id, :integer
    add_column :voucher, :migration_completed, :boolean, default: false
  end
end
