class GeneralSettingsController < ApplicationController
  before_action -> {authorize self}
  before_action :set_return_path

  def set_fy
    fy_code = params[:fy_code].to_i
    branch_id = params[:branch_id].to_i
    # return_back
    requested_url = request.referrer.split("/")
    requested_url[3] = fy_code
    requested_url[4] = branch_id
    redirect_to requested_url.join("/")
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
