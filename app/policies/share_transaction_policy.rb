class ShareTransactionPolicy < ApplicationPolicy
  # four actions in menu
  # need to distinguish cancelled transactions from index
  permit_conditional_access_to_employee_and_above :index, :deal_cancel, :pending_deal_cancel, :threshold_transactions, :contract_note_details, :closeouts
  permit_conditional_access_to_client_and_above :index

  permit_custom_access :employee_and_above, share_transactions_path, [:new, :show, :create, :update, :edit, :destroy, :capital_gain_report, :threshold_transactions, :contract_note_details, :securities_flow, :sebo_report, :commission_report]

  permit_custom_access :employee_and_above, closeouts_share_transactions_path, [:make_closeouts_processed, :process_closeout, :available_balancing_transactions]
end