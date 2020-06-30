class EdisReportPolicy < ApplicationPolicy
  permit_conditional_access_to_client_and_above  :import
  permit_custom_access :employee_and_above, import_edis_reports_path(0,0), [:index, :create, :show, :process_import]
end
