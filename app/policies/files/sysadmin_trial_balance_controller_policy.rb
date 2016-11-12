class Files::SysadminTrialBalanceControllerPolicy < ApplicationPolicy
  # def initialize(user, ctlr)
  #   @user = user
  #   @ctlr = ctlr
  # end

  # no controller actions in menu
  # permit_unconditional_access_to_employee_and_above :index, :new, :import, :get_base_price
  permit_unconditional_access_to_admin_and_above :new, :import, :index
end