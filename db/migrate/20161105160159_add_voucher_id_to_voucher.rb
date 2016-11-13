class AddVoucherIdToVoucher < ActiveRecord::Migration
  def change
    add_column :voucher, :voucher_id, :integer
    add_column :voucher, :migration_completed, :boolean, default: false
  end
end
