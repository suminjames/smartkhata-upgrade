class EmployeeAccountPolicy < ApplicationPolicy
  permit_access_to_employee_and_above :index, :show, :new, :edit, :create, :update, :destroy
end