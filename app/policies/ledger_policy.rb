class LedgerPolicy < ApplicationPolicy
  permit_access_to_employee_and_above :index, :show, :new, :edit, :create, :update, :destroy, :group_members_ledgers, :transfer_group_member_balance, :cashbook, :daybook
end
