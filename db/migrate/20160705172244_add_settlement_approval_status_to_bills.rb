class AddSettlementApprovalStatusToBills < ActiveRecord::Migration
  def change
    add_column :bills, :settlement_approval_status, :integer, default: 0, index: true
  end
end
