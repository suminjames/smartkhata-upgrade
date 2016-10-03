class BillPolicy < ApplicationPolicy
  permit_access_to_client_and_above :index, :show
  permit_access_to_employee_and_above :process_selected, :new, :create, :sales_payment

  def sales_payment_process?
    employee_and_above? sales_payment_bills_path
  end

  # unless you can see ledgers you can not process selected bills
  def process_selected?
    employee_and_above? bills_path
  end
end
