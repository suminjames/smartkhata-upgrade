class NepseSettlementPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :new, :ajax_filter

  permit_custom_access :employee_and_above, new_nepse_settlement_path(0,0), [:index, :show, :create, :update, :edit, :destroy, :generate_bills]
end
