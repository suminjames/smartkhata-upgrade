class ReceiptTransactionPolicy < ApplicationPolicy
  permit_conditional_access_to_employee_and_above :index, :combobox_ajax_filter
end
