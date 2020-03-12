class UserAccessRolePolicy < ApplicationPolicy
  # two actions in menu
  permit_conditional_access_to_employee_and_above :index, :new

  permit_custom_access :employee_and_above, new_user_access_role_path(0,0), [:edit, :update, :create, :destroy]
  permit_custom_access :employee_and_above, user_access_roles_path(0,0), [:show]
end
