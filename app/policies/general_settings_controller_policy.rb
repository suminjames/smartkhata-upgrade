class GeneralSettingsControllerPolicy < ApplicationPolicy
  # no controller actions in menu
  permit_unconditional_access_to_employee_and_above GeneralSettingsController
end
