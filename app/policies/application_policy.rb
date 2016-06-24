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


  def admin_and_above?
    user.admin? || user.sys_admin?
  end
  def employee_and_above?
    user.employee? || user.admin? || user.sys_admin?
  end

  def client_and_above?
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

  private

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

end
