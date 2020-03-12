class Files::Dpa5ControllerPolicy < ApplicationPolicy
	attr_reader :current_user, :ctlr

  def initialize(user, ctlr)
    @user = user
    @ctlr = ctlr
  end

  permit_conditional_access_to_employee_and_above :new
  permit_custom_access :employee_and_above, new_files_dpa5_path(0,0), [:index, :import], true
end
