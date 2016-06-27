class BankPolicy < ApplicationPolicy
  permit_access_to_employee_and_above :index, :show, :process_selected, :new
end