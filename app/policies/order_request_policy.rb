class OrderRequestPolicy < ApplicationPolicy
  # the only action in menu
  def new?
    user.client? || path_authorized_to_employee_and_above?
  end

  def edit?
    record_allowed_for_user(record, user)
  end

  def create?
    path_authorized_to_employee_and_above? || user.client?
  end
  def update?
    record_allowed_for_user(record, user)
  end

  def record_allowed_for_user(record, user)
    path_authorized_to_employee_and_above? || user.client_accounts.include?(record.client_account)
  end
end