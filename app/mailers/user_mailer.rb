include ApplicationHelper

class UserMailer < ApplicationMailer

  def bill_email (transaction_message_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    @transaction_message = TransactionMessage.find_by_id(transaction_message_id)
    @transaction_message.email_queued!
    @bill = @transaction_message.bill
    email = @transaction_message.client_account.email
    subject = "Your bill from #{@current_tenant.full_name}"
    bill_pdf = Print::PrintBill.new(@bill.decorate, @current_tenant, 'for_email')
    attachments["Bill_#{@bill.date}_#{@bill.bill_number}.pdf"] = bill_pdf.render
    mail(
        from: "#{@current_tenant.name}@danpheinfotech.com",
        to: email,
        subject: subject
    )
    @transaction_message.increase_sent_email_count!
    @transaction_message.email_sent!
  end

  def transaction_message_email (transaction_message_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    @transaction_message = TransactionMessage.find_by_id(transaction_message_id)
    @transaction_message.email_queued!
    email = @transaction_message.client_account.email
    subject = "Your transaction message from #{@current_tenant.full_name}"
    transaction_message_pdf = Pdf::PdfTransactionMessage.new(@transaction_message.transaction_date, @transaction_message.client_account, @current_tenant)
    attachments["TransactionMessage_#{@transaction_message.transaction_date}_#{@transaction_message.id}.pdf"] = transaction_message_pdf.render
    mail(
        from: "#{@current_tenant.name}@danpheinfotech.com",
        to: email,
        subject: subject
    )
    @transaction_message.increase_sent_email_count!
    @transaction_message.email_sent!
  end
end
