class GeneralSettingsController < ApplicationController
  before_action -> {authorize self}
  before_action :set_return_path

  def set_fy
    fy_code = params[:fy_code].to_i
    branch_id = params[:branch_id].to_i
    # set_user_selected_branch_fy_code(branch_id, fy_code)
    # return_back
    # debugger
    redirect_to root_path(selected_branch_id: branch_id, selected_fy_code: fy_code)
  end

  def set_branch
  end

  private
  # set the path to referer only in case of get request.
  # in case of post request path is root path
  def set_return_path
    session[:return_to] = request.referer || root_path
  end

  def return_back
    redirect_to session.delete(:return_to)
  end
end
