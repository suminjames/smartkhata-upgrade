class EmployeeAccountPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index, :employee_access

  permit_custom_access :employee_and_above, employee_accounts_path, [:new, :show, :edit, :create, :update, :destroy, :combobox_ajax_filter]
  # hidden menu item
  permit_custom_access :employee_and_above, employee_accounts_employee_access_path, [:update_employee_access]
end
