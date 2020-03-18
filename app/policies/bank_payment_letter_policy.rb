class BankPaymentLetterPolicy < ApplicationPolicy
  # the only action in menu
  permit_conditional_access_to_employee_and_above :index

  permit_custom_access :employee_and_above, bank_payment_letters_path(0,0), [:new, :show, :edit, :create, :update, :edit, :destroy]
  permit_custom_access :employee_and_above, bank_payment_letters_path(0,0), [:finalize_payment]
end
