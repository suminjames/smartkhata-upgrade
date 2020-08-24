class EdisItemPolicy < ApplicationPolicy
  permit_conditional_access_to_client_and_above  :import
  permit_custom_access :employee_and_above, import_edis_items_path(0,0), [:index, :create, :show, :update, :process_import]
end
