class GeneralSettingsController < ApplicationController
  before_action -> {authorize self}

  def set_fy
    redirect_to root_path if request.referrer.blank?

    fy_code = params[:fy_code].to_i
    branch_id = params[:branch_id].to_i
    # return_back
    requested_url = request.referrer.split("/")
    requested_url[3] = fy_code
    requested_url[4] = branch_id
    redirecting_url = request.get? ? requested_url.join("/") : root_path
    redirect_to redirecting_url
  end

  def set_branch
  end
end
