class NepseChalanPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, nepse_chalans_path(0,0), [:new, :show, :create, :update, :edit, :destroy]
end
