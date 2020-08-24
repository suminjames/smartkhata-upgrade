class MergeRebatePolicy < ApplicationPolicy
  permit_conditional_access_to_employee_and_above :index
  permit_custom_access :employee_and_above, merge_rebates_path(0,0), [:new, :create, :edit, :update, :destroy]
end
