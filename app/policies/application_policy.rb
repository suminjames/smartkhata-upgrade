class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def sys_admin?
    user.sys_admin?
  end

  def admin?
    user.admin?
  end

  #
  # authorization for employee and above requires the permitted actions for a user
  #
  def employee_and_above?
    # admin and sys admin dont have restrictions
    return true if user.admin? || user.sys_admin?
    if user.employee?
      # deny access for the urls
      # TODO(subas) incorporate post / get methods
      return true if !user.blocked_path_list.include? user.current_url_link
    end
    return false
  end

  def client_and_above?
    user.client? || user.employee? || admin?
  end

  def client_or_agent?
    user.client? || user.agent?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def self.permit_access_to_sysadmin(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        sys_admin?
      end
    end
  end

  def self.permit_access_to_admin(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        admin?
      end
    end
  end

  def self.permit_access_to_employee_and_above(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        employee_and_above?
      end
    end
  end

  def self.permit_access_to_client_and_above(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        client_and_above?
      end
    end
  end

  def self.permit_access_to_client_or_agent(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        client_or_agent?
      end
    end
  end

end
