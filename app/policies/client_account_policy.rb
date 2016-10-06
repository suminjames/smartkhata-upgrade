class ClientAccountPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, new_client_account_path, [:new, :create, :edit, :destroy]
  permit_custom_access :employee_and_above, client_accounts_path, [:combobox_ajax_filter]

  def show?
    user == record || path_authorized_to_employee_and_above?
  end

  def update?
    user == record || path_authorized_to_employee_and_above?
  end
end
