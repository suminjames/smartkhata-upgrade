class TransactionMessagePolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, transaction_messages_path, [:new, :show, :create, :create_multiple, :update, :edit, :destroy]
  permit_custom_access :employee_and_above, transaction_messages_path, [:send_email, :send_sms, :sent_status]
end