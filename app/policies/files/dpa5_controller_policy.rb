class Files::Dpa5ControllerPolicy < ApplicationPolicy
	attr_reader :current_user, :ctlr

  def initialize(user, ctlr)
    @user = user
    @ctlr = ctlr
  end

  def new?
    employee_and_above?(new_files_dpa5_path)
  end
  # permit_access_to_employee_and_above :new, :index


  def employee_and_above?(link = nil)
    # admin and sys admin dont have restrictions
    return true if user.admin? || user.sys_admin?
    if user.employee?
      if link
        return true if !user.blocked_path_list.include? link
      else
        return true if !user.blocked_path_list.include? user.current_url_link
      end
    end
    return false
  end
end