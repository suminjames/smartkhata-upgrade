class SettlementPolicy < ApplicationPolicy
  # three actions in menu: need to distinguish all/receipt/payment
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, settlements_path(0,0), [:new, :show, :show_multiple, :create, :update, :edit, :destroy]
end
