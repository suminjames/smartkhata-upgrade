class Reports::AuditTrailsControllerPolicy < ApplicationPolicy
  # the only action in menu as well as controller
  permit_unconditional_access_to_admin_and_above :index
end