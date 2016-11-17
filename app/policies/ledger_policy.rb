class LedgerPolicy < ApplicationPolicy
  # three actions in menu
  permit_conditional_access_to_employee_and_above :index, :group_members_ledgers, :new

  # hidden menu item
  permit_custom_access :employee_and_above, new_ledger_path, [:create, :update, :edit, :destroy]

  permit_custom_access :employee_and_above, group_member_ledgers_path, [:transfer_group_member_balance]
  permit_custom_access :employee_and_above, ledgers_path, [:show, :combobox_ajax_filter]

  # actions remaining to be added: :cashbook, :daybook
  def show_all?
    @user.admin?
  end
end