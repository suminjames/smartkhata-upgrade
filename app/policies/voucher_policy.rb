class VoucherPolicy < ApplicationPolicy
  # two actions in menu
  # How to add arguments to action (:new voucher types)?
  permit_conditional_access_to_employee_and_above :new, :pending_vouchers

  permit_custom_access :employee_and_above, new_voucher_path(0,0), [:convert_date, :create, :update, :edit, :destroy]
  permit_custom_access :employee_and_above, new_voucher_path(0,0), [:index, :finalize_payment, :set_bill_client]

  def show?
    employee_and_above?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
