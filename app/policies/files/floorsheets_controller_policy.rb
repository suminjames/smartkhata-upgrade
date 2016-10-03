class Files::FloorsheetsControllerPolicy < ApplicationPolicy
	attr_reader :current_user, :ctlr

  def initialize(current_user, ctlr)
    @current_user = current_user
    @ctlr = ctlr
  end

  def new?
    @current_user.admin? or @current_user.manager? or @current_user.supervisor?
  end

  def import?
    @current_user.admin? or @current_user.manager? or @current_user.supervisor?
  end

  def index?
    @current_user.admin? or @current_user.manager? or @current_user.supervisor?
  end
end