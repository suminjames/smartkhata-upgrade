class BankAccountPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, bank_accounts_path, [:index, :show, :create, :update, :edit, :destroy]
end