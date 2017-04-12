class BillPolicy < ApplicationPolicy
  # three actions in menu
  permit_conditional_access_to_client_and_above :index
  permit_conditional_access_to_employee_and_above :new, :sales_payment

  permit_custom_access :employee_and_above, new_bill_path, [:create, :update, :edit, :destroy]
  permit_custom_access :employee_and_above, ageing_analysis_bills_path, [:ageing_analysis]

  permit_custom_access :employee_and_above, sales_payment_bills_path, [:sales_payment_process]
  # unless you can see ledgers you can not process selected bills
  permit_custom_access :employee_and_above, bills_path, [:process_selected, :show_multiple]
  permit_custom_access :employee_and_above, bills_path, [:select_for_settlement]

  def show?
    if @user.client?
      client_account_ids = @user.client_accounts.pluck(:id)
      if client_account_ids.include?(@record.client_account_id)
        return true
      end
    else
      path_authorized_to_employee_and_above?(self.class.bills_path)
    end
  end
end
