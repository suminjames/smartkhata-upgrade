class BrokerProfilePolicy < ApplicationPolicy
  permit_conditional_access_to_employee_and_above :index, :new, :show, :create, :update, :edit, :destroy
end
