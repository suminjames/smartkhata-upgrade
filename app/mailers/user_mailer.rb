include ApplicationHelper

class UserMailer < ApplicationMailer

  def bill_email (bill, current_tenant)
    @bill = bill
    @current_tenant = current_tenant
    email = @bill.client_account.email
    subject = "Your bill from #{current_tenant.full_name}"
    bill_pdf = Print::PrintBill.new(@bill.decorate, current_tenant)
    attachments['Bill.pdf'] = bill_pdf.render
    mail(to: email, subject: subject)
  end

end
