class Files::SysadminClientNepseMappingControllerPolicy < ApplicationPolicy
  permit_access_to_admin :new, :import, :index, :nepse_phone
end