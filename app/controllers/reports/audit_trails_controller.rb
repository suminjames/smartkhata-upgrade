class Reports::AuditTrailsController < ApplicationController
  def index
    @audit_trails = AuditTrail.includes(:user).all.page(params[:page]).per(20)
  end
end
