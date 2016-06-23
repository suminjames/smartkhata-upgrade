class HardWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(bill_id, current_tenant)

    bill = Bill.find_by_id(bill_id)
    UserMailer.delay.bill_email(bill_id, current_tenant)
  end

end
