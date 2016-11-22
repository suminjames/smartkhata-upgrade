class VisitorsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_after_action :verify_authorized

  def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  end

  def index

    if user_signed_in?
      if current_user.client?
        redirect_to :controller => 'dashboard', :action => 'client_index'
      else
        redirect_to :controller => 'dashboard', :action => 'index'
      end
    end

    # @ssl_client_fingerprint = request.env["X-SSL-Client-Fingerprint"]
    # @ssl_client_s_dn = request.env["X-SSL-Client-S-DN"]
    # @ssl_client_cert = request.env["X-SSL-Client-I-DN"]
    # @ssl_client_serial = request.env["X-SSL-Client-Serial"]
    # @ssl_client_verify = request.env["X-CLIENT-VERIFY"]

    @subject = request.headers.env["HTTP_X_SSL_CLIENT_S_DN"]
    my_logger.info("Subject  #{@subject}")

  end
end
