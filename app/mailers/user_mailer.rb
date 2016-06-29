include ApplicationHelper

class UserMailer < ApplicationMailer

  def bill_email (transaction_message_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    @transaction_message = TransactionMessage.find_by_id(transaction_message_id)
    @transaction_message.email_queued!
    @bill = @transaction_message.bill
    email = @bill.client_account.email
    subject = "Your bill from #{@current_tenant.full_name}"
    bill_pdf = Print::PrintBill.new(@bill.decorate, @current_tenant)
    attachments['Bill.pdf'] = bill_pdf.render
    mail(from: "#{@current_tenant.name}@danpheinfotech.com",
         to: email,
         subject: subject)
    @transaction_message.increase_sent_email_count!
    @transaction_message.email_sent!
    Apartment::Tenant.switch!('public')
  end

end
