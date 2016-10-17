class MenuPermissionPolicy < ApplicationPolicy
  permit_conditional_access_to_employee_and_above :index, :show, :new

  permit_custom_access :employee_and_above, new_menu_permission_path, [:create, :edit, :update, :destroy]
end