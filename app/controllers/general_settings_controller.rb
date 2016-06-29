class GeneralSettingsController < ApplicationController
  before_action :set_return_path

  def set_fy
    fy_code = params[:fy_code].to_i
    set_user_selected_fy_code(fy_code)
    return_back
  end

  def set_branch
  end

  private
  # set the path to referer only in case of get request.
  # in case of post request path is root path
  def set_return_path
    session[:return_to] = request.get? ? request.referer : root_path
  end

  def return_back
    redirect_to session.delete(:return_to)
  end
end