class EmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true

  def perform(bill_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    UserMailer.bill_email(bill_id, current_tenant_id)
    Apartment::Tenant.switch!('public')
  end

end
