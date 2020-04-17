class AddSettlementApprovalStatusToBills < ActiveRecord::Migration[4.2]
  def change
    add_column :bills, :settlement_approval_status, :integer, default: 0, index: true
  end
end
