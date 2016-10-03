class LedgerPolicy < ApplicationPolicy
  permit_access_to_employee_and_above :index, :show, :new, :group_members_ledgers, :transfer_group_member_balance, :cashbook, :daybook

  def create?
    employee_and_above?(new_ledger_path)
  end

  def edit?
    employee_and_above?(new_ledger_path)
  end

  def update?
    employee_and_above?(new_ledger_path)
  end

  def destroy?
    employee_and_above?(new_ledger_path)
  end

  def combobox_ajax_filter?
    employee_and_above?(ledgers_path)
  end
end