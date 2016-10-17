class Report::ProfitandlossControllerPolicy < ApplicationPolicy
  # the only action in menu as well as controller
  permit_conditional_access_to_employee_and_above :index
end