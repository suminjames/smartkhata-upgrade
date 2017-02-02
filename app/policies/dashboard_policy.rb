class DashboardPolicy < Struct.new(:user, :dashboard)
  def index?
    user.present? && !user.client?
  end

  def client_index?
    user.present? &&  user.client? && user.client_accounts.present?
  end
end
