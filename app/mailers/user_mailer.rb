include ApplicationHelper

class UserMailer < ApplicationMailer

  def bill_email (bill_id, current_tenant_id)
    @bill = Bill.find_by_id(bill_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    bill = @bill
    email = bill.client_account.email
    subject = "Your bill from #{@current_tenant.full_name}"
    bill_pdf = Print::PrintBill.new(@bill.decorate, @current_tenant)
    attachments['Bill.pdf'] = bill_pdf.render
    mail(to: email, subject: subject)
  end

end
