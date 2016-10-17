class Files::CalendarsControllerPolicy < ApplicationPolicy
  # no controller actions in menu
  permit_unconditional_access_to_employee_and_above Files::CalendarsController
end