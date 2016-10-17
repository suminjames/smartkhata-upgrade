class OrderPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, orders_path, [:show, :is_active_sub_menu_option]
end