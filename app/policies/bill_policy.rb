class BillPolicy < ApplicationPolicy
  # three actions in menu
  permit_conditional_access_to_client_and_above :index
  permit_conditional_access_to_employee_and_above :new, :sales_payment

  permit_custom_access :employee_and_above, new_bill_path, [:create, :update, :edit, :destroy]

  permit_custom_access :employee_and_above, sales_payment_bills_path, [:sales_payment_process]
  # unless you can see ledgers you can not process selected bills
  permit_custom_access :employee_and_above, bills_path, [:process_selected, :show]
end
