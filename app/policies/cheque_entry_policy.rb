class ChequeEntryPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above,
                       cheque_entries_path(0,0),
                       [
                           :new,
                           :show,
                           :show_multiple,
                           :create,
                           :update,
                           :edit,
                           :destroy,
                           :get_cheque_number,
                           :update_print_status,
                           :settlements_associated_with_cheque_entries,
                           :bills_associated_with_cheque_entries,
                           :make_cheque_entries_unprinted,
                           :combobox_ajax_filter_for_beneficiary_name
                       ]

  permit_custom_access_branch_restricted :employee_and_above,
                       cheque_entries_path(0,0),
                       [
                           :bounce_show,
                           :bounce_do,
                           :represent_show,
                           :represent_do,
                           :void_show,
                           :void_do,
                       ]
end
