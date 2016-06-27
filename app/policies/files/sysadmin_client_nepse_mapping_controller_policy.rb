class Files::SysadminClientNepseMappingControllerPolicy
	attr_reader :current_user, :ctlr

  def initialize(current_user, ctlr)
    @current_user = current_user
    @ctlr = ctlr
  end

  def new?
    @current_user.sys_admin?
  end

  def import?
    @current_user.sys_admin?
  end

  def index?
    @current_user.sys_admin?
  end
end