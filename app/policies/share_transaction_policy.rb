class ShareTransactionPolicy < ApplicationPolicy
  # four actions in menu
  # need to distinguish cancelled transactions from index
  permit_conditional_access_to_employee_and_above :index, :deal_cancel, :pending_deal_cancel

  permit_custom_access :employee_and_above, share_transactions_path, [:new, :show, :create, :update, :edit, :destroy, :capital_gain_report, :threshold_transactions]
end