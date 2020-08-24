class EdisReportPolicy < ApplicationPolicy
  permit_conditional_access_to_client_and_above  :import, :new
  permit_custom_access :employee_and_above, import_edis_reports_path(0,0), [:index, :show, :process_import]
  permit_custom_access :employee_and_above, new_edis_report_path(0,0), [:create]
end
