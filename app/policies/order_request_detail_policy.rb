class OrderRequestDetailPolicy < ApplicationPolicy
  # the only action in menu
  def index?
    user.client? || path_authorized_to_employee_and_above?
  end

  def client_report?
    path_authorized_to_employee_and_above?
  end

  def edit?
    record_allowed_for_user(record, user)
  end

  def update?
    record_allowed_for_user(record, user)
  end

  def destroy?
    record_allowed_for_user(record, user)
  end

  def record_allowed_for_user(record, user)
    path_authorized_to_employee_and_above? || user.client_accounts.include?(record.client_account)
  end

  def approve?
    path_authorized_to_employee_and_above?
  end
  def reject?
    path_authorized_to_employee_and_above?
  end
end