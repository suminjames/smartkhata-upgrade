class ApplicationPolicy
  attr_reader :user, :record

  class << self
    include Rails.application.routes.url_helpers
  end

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

  # Methods to check single user designation with ease
  def sys_admin?
    user.sys_admin?
  end

  def admin?
    user.admin?
  end

  def employee?
    user.employee?
  end

  def client?
    user.client?
  end

  # blacklisting: the current implementation
  def authorized_to_access?(link)
    return false unless link
    return unless user.can_access_branch?
    link_params = link.split('/')
    link = "/:fy_code/:branch_id/#{link_params[3..-1].join('/')}"
    !user.blocked_path_list.include?(link)
  end

  #
  # authorization for <designation> and above requires the permitted actions for a user
  #
  # admin and sys admin dont have restrictions

  def path_authorized_to_employee_and_above?(link=user.current_url_link)
    admin_and_above? || (employee? && authorized_to_access?(link))
  end

  def path_authorized_to_client_and_above?(link=user.current_url_link)
    admin_and_above? || client? || (employee? && authorized_to_access?(link))
  end


  # Methods to check user designation groups
  def admin_and_above?
    admin? || sys_admin?
  end

  def employee_and_above?
    employee? || admin_and_above?
  end

  def client_and_above?
    client? || employee_and_above?
  end

  def client_or_agent?
    client? || agent?
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

  # not yet used
  # def self.permit_unconditional_access_to_sysadmin(*actions)
  #   actions.each do |action|
  #     define_method("#{action}?") do
  #       sys_admin?
  #     end
  #   end
  # end

  def self.permit_unconditional_access_to_admin_and_above(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        admin_and_above?
      end
    end
  end

  # conditional means it also checks whether the user is authorized to access the link, besides user designation.
  def self.permit_conditional_access_to_employee_and_above(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        path_authorized_to_employee_and_above?
      end
    end
  end

  def self.permit_conditional_access_to_client_and_above(*actions)
    actions.each do |action|
      define_method("#{action}?") do
        path_authorized_to_client_and_above?
      end
    end
  end

  # not yet used
  # def self.permit_conditional_access_to_client_or_agent(*actions)
  #   actions.each do |action|
  #     define_method("#{action}?") do
  #       # need to define method:
  #       path_authorized_to_client_or_agent?
  #     end
  #   end
  # end

  #
  # If the `privilege` passed in has access to the given `path`, provide `privilege` with access to passed `actions`
  #
  def self.permit_custom_access(privilege, path, actions, global_action = true)
    actions.each do |action|
      define_method("#{action}?") do
        # return false if user cant read write
        # hack for show action
        unless( action == :show) || global_action || (@user.can_read_write?)
          return false
        end
        privilege = privilege.to_s
        # mapping privilege text to original method
        if privilege == 'employee_and_above'
          privilege.prepend "path_authorized_to_"
        end
        self.send("#{privilege}?", path)
      end
    end
  end

  def self.permit_custom_access_branch_restricted(privilege, path, actions)
    permit_custom_access(privilege, path, actions, false)
  end


  # For controllers (& related actions) that are not included in the User Access Role menu
  def self.permit_unconditional_access_to_employee_and_above(param)
    # param can be a controller(usual case) or actions array
    # fetch actions if controller passed
    actions = (param < ApplicationController) ? param.instance_methods(false) : param

    actions.each do |action|
      define_method("#{action}?") do
        employee_and_above?
      end
    end
  end

end
