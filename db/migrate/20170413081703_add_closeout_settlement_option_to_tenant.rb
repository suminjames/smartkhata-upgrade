class AddCloseoutSettlementOptionToTenant < ActiveRecord::Migration[4.2]
  def change
    add_column :tenants, :closeout_settlement_automatic, :boolean, default: :false
  end
end
