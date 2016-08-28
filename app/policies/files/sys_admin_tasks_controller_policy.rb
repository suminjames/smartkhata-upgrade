class Files::SysAdminTasksControllerPolicy < ApplicationPolicy
  permit_access_to_admin :new, :import
end