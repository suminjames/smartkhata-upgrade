class ClientAccountPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, new_client_account_path, [:new, :create, :edit, :destroy]
  permit_custom_access :employee_and_above, client_accounts_path, [:combobox_ajax_filter]

  def show?
    user_has_access_to_record(record, user)
  end

  def update?
    user == record || path_authorized_to_employee_and_above?
  end

  #
  # A user has_many client_accounts.
  # This method checks to see if the record(client_account) in question in associated with the user.
  #
  def user_has_access_to_record(record, user)
    path_authorized_to_employee_and_above? || user.client_accounts.include?(record)
  end
end
