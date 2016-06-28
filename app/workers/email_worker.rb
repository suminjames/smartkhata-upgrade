class EmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => true

  def perform(bill_id, current_tenant_id)
    UserMailer.delay.bill_email(bill_id, current_tenant_id)
  end

end
