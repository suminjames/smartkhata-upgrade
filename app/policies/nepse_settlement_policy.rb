class NepseSettlementPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :new

  permit_custom_access :employee_and_above, new_nepse_settlement_path, [:index, :show, :create, :update, :edit, :destroy, :generate_bills]
end