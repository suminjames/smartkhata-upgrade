class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApplicationHelper
  # The following method has been influenced by http://stackoverflow.com/questions/2385799/how-to-redirect-to-a-404-in-rails
  def record_not_found
    #  raise ActiveRecord::RecordNotFound.new('Record Not Found')
    #TODO Create a custom 'Record Not Found' or similar 405 page instead of using 404.html
    render :file => "#{Rails.root}/public/404.html",  :status => 404
  end

end
