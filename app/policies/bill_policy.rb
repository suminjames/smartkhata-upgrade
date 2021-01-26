class BillPolicy < ApplicationPolicy
  # three actions in menu
  permit_conditional_access_to_client_and_above :index
  permit_conditional_access_to_employee_and_above :new, :sales_payment, :send_email

  permit_custom_access :employee_and_above, new_bill_path(0,0), [:create, :update, :edit, :destroy]
  permit_custom_access :employee_and_above, ageing_analysis_bills_path(0,0), [:ageing_analysis]

  permit_custom_access :employee_and_above, sales_payment_bills_path(0,0), [:sales_payment_process], true
  # unless you can see ledgers you can not process selected bills
  permit_custom_access :employee_and_above, bills_path(0,0), [:process_selected, :show_multiple]
  permit_custom_access :employee_and_above, bills_path(0,0), [:select_for_settlement]

  def show?
    if @user.client?
      client_account_ids = @user.client_accounts.pluck(:id)
      return true if client_account_ids.include?(@record.client_account_id)
    else
      path_authorized_to_employee_and_above?(self.class.bills_path(0, 0))
    end
  end
end
