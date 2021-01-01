class AddCommissionTypeToMasterCommissionDetails < ActiveRecord::Migration
  def change
    add_column :master_setup_commission_infos, :group, :integer, default: 0
  end
end
