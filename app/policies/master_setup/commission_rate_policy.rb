class MasterSetup::CommissionRatePolicy < ApplicationPolicy
  # TODO(sarojk): Implement other accesses too.
  permit_unconditional_access_to_admin_and_above :index, :new, :show, :create, :update, :edit, :destroy
end