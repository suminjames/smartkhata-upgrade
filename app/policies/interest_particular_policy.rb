class InterestParticularPolicy < ApplicationPolicy
  # permit_unconditional_access_to_admin_and_above :new, :show, :create, :update, :edit, :destroy
  permit_conditional_access_to_employee_and_above :index
end
