class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # extend ActiveSupport::Concern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  include ApplicationHelper

  # Callbacks
  before_action :authenticate_user!, :unless => :devise_controller?
  before_action :set_user_session, if: :user_signed_in?
  before_action :set_branch_fy_params, if: :user_signed_in?
  # after_action :verify_authorized, :unless => :devise_controller?

  # method from menu permission module
  before_action :get_blocked_path_list, if: :user_signed_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # The following method has been influenced by http://stackoverflow.com/questions/2385799/how-to-redirect-to-a-404-in-rails
  def record_not_found
    #  raise ActiveRecord::RecordNotFound.new('Record Not Found')
    #TODO Create a custom 'Record Not Found' or similar 405 page instead of using 404.html
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  private

  def current_tenant
    @current_tenant ||= Tenant.find_by(name: request.subdomain)
  end

  helper_method :current_tenant

  def user_not_authorized
    flash[:alert] = "Access denied."
    redirect_to (request.referrer || root_path)
  end

  # Uses the helper methods from devise to made them available in the models
  def set_user_session
    current_user.current_url_link = request.path
    UserSession.user = current_user
    UserSession.selected_fy_code ||= get_fy_code
    session[:user_selected_fy_code] ||= get_fy_code
    session[:user_selected_branch_id] ||= current_user.branch_id
    # session[:blocked_path_list] ||= get_blocked_path_list
  end

  #   set the default fycode and branch params
  def set_branch_fy_params
    params[:by_fy_code] ||= get_fy_code
    params[:by_branch] ||= current_user.branch_id
  end
end
