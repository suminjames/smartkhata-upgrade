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
  # after_action :verify_authorized, :unless => :devise_controller?
  before_action :set_user_session, if: :user_signed_in?

  # The following method has been influenced by http://stackoverflow.com/questions/2385799/how-to-redirect-to-a-404-in-rails
  def record_not_found
    #  raise ActiveRecord::RecordNotFound.new('Record Not Found')
    #TODO Create a custom 'Record Not Found' or similar 405 page instead of using 404.html
    render :file => "#{Rails.root}/public/404.html",  :status => 404
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

  def current_fy_code
    get_fy_code
  end
  helper_method :current_fy_code

  # Uses the helper methods from devise to made them available in the models
  def set_user_session
    UserSession.user = current_user
  end

end
