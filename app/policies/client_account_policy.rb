class ClientAccountPolicy < ApplicationPolicy
  permit_access_to_employee_and_above :new, :index, :create, :destroy

  def show?
    user == record || employee_and_above?
  end

  def update?
    user == record || employee_and_above?
  end
end
