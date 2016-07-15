class BillPolicy < ApplicationPolicy
  permit_access_to_client_and_above :index, :show
  permit_access_to_employee_and_above :process_selected, :new, :create
end
