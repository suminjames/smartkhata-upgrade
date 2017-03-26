class UserPolicy < ApplicationPolicy
  # attr_reader :current_user, :model

  include Rails.application.routes.url_helpers

  # def initialize(current_user, model)
  #   @current_user = current_user
  #   @user = model
  # end

  def index?
    @user.admin?
  end

  def show?
    @user.admin? or @user == @record
  end

  def update?
    @user.admin?
  end

  def destroy?
    return false if @user == @record
    @user.admin?
  end

  def reset_temporary_password?
    path_authorized_to_employee_and_above?(client_accounts_path)
  end
end
