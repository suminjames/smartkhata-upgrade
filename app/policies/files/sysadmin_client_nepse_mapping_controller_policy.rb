class Files::SysadminClientNepseMappingControllerPolicy < ApplicationPolicy
  permit_access_to_sysadmin :new, :import, :index
end