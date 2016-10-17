class Files::SysadminClientNepseMappingControllerPolicy < ApplicationPolicy
  # no controller actions in menu
  permit_unconditional_access_to_admin_and_above :new, :import, :index, :nepse_phone, :nepse_boid, :get_base_price
end