class AddCloseoutSettlementOptionToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :closeout_settlement_automatic, :boolean, default: :false
  end
end
