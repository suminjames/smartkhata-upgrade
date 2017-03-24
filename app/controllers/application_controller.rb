class ApplicationController < ActionController::Base

  before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_mailer_host

  # extend ActiveSupport::Concern

  include ApplicationHelper

  # Callbacks
  before_action :authenticate_user!, :unless => :devise_controller?
  before_action :set_user_session, if: :user_signed_in?
  before_action :set_branch_fy_params, if: :user_signed_in?
  after_action :verify_authorized, :unless => :devise_controller?

  # method from menu permission module
  before_action :get_blocked_path_list, if: :user_signed_in?
  # before_action :get_allowed_branch, if: :user_signed_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActionController::RoutingError, with: :fy_code_route_mismatch
  # resuce_from SmartKhata::Error::Branch, with: :branch_access_error

  # The following method has been influenced by http://stackoverflow.com/questions/2385799/how-to-redirect-to-a-404-in-rails
  def record_not_found
    #  raise ActiveRecord::RecordNotFound.new('Record Not Found')
    #TODO Create a custom 'Record Not Found' or similar 405 page instead of using 404.html
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  private

  def current_tenant
    @current_tenant ||= Tenant.find_by(name: request.subdomain)
    @current_tenant ||= Tenant.find_by(name: 'smartkhata')
  end

  helper_method :current_tenant

  def set_mailer_host
    # subdomain = current_tenant ? "#{current_tenant.name}." : ""
    # ActionMailer::Base.default_url_options[:host] = "#{subdomain}#{Rails.application.secrets.domain_name}"
    ActionMailer::Base.default_url_options[:host] = request.host
  end

  def fy_code_route_mismatch
    session[:return_to] = root_path
    redirect_to root_path
  end

  def branch_access_error
    flash[:alert] = "You are not authorized to access any branch. Please contact administrator"
    session[:return_to] = root_path

    # for logged in users it is dashboard
    # for visitors its root path
    if user_signed_in?
      if request.path == destroy_user_session_path
        # do nothing
        #   carry on with the request execution
      else
        redirect_to root_path if request.path != '/dashboard/index' && request.path != root_path
      end
    else
      redirect_to root_path
    end
  end

  def user_not_authorized
    flash[:alert] = "Access denied."
    redirect_to (request.referrer || root_path)
  end

  # Uses the helper methods from devise to made them available in the models
  def set_user_session
    current_user.current_url_link = request.path
    UserSession.user = current_user
    UserSession.tenant = current_tenant

    # session storage for controllers
    session[:user_selected_fy_code] ||= get_fy_code

    branch_id = get_preferrable_branch_id

    branch_access_error unless branch_id.present?

    session[:user_selected_branch_id] ||= branch_id

    # set the session variable for the session
    UserSession.selected_fy_code = session[:user_selected_fy_code]
    UserSession.selected_branch_id = session[:user_selected_branch_id]
  end

  #   set the default fycode and branch params
  def set_branch_fy_params
    params[:by_fy_code] ||= get_fy_code
    params[:by_branch] ||= current_user.branch_id
  end

  # added username as permitted parameters
  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def get_preferrable_branch_id
    if current_user.admin?
      Branch.first.id
    else
      available_branches_ids = available_branches.pluck(:id)
      if available_branches_ids.include? current_user.branch_id
        current_user.branch_id
      else
        available_branches_ids.first
      end
    end

  end
end
