class VisitorsController < ApplicationController
  
  skip_before_filter :authenticate_user!
  skip_after_action :verify_authorized
  skip_before_action :validate_certificate

  def index
    @invalid_certificate = nil
    if user_signed_in? &&  valid_certificate?(current_user)
    # if user_signed_in?
      if current_user.client?
        redirect_to :controller => 'dashboard', :action => 'client_index'
      else
        redirect_to :controller => 'dashboard', :action => 'index'
      end
    elsif user_signed_in?
      @invalid_certificate = true
    elsif user_signed_in?
      redirect_to '/users/sign_in'
    end

  end
end
