class InterestRatePolicy < ApplicationPolicy
  permit_unconditional_access_to_admin_and_above :index, :new, :show, :create, :update, :edit, :destroy
end
