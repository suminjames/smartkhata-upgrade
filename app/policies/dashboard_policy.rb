class DashboardPolicy < Struct.new(:user, :dashboard)
  def index?
    user.present?
  end
end