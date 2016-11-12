class VendorAccountPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, vendor_accounts_path, [:new, :show, :edit, :create, :update, :destroy]
end
