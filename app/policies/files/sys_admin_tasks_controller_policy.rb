class Files::SysAdminTasksControllerPolicy < ApplicationPolicy
  # no controller actions in menu
  permit_unconditional_access_to_admin_and_above :new, :import
end