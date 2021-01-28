class AddCommissionTypeToMasterCommissionDetails < ActiveRecord::Migration[4.2]
  def change
    add_column :master_setup_commission_infos, :group, :integer, default: 0
  end
end
