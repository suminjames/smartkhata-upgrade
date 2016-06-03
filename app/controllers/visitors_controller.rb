class VisitorsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_after_action :verify_authorized

  def index
    if user_signed_in?
      redirect_to :controller=>'dashboard', :action =>'index'
    end
  end
end
