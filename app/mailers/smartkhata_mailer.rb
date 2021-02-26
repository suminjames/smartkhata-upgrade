class SmartkhataMailer < ApplicationMailer
  include ApplicationHelper

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
        from: sender,
        to: email,
        subject: subject,
        template_path: 'smartkhata_mailer'
    )
    @transaction_message.increase_sent_email_count!
    @transaction_message.email_sent!
  end

  def transaction_message_email (transaction_message_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    @transaction_message = TransactionMessage.find_by_id(transaction_message_id)

    @bill = @transaction_message.bill if @transaction_message.bill.present? && @transaction_message.bill.bill_type == "purchase"

    @transaction_message.email_queued!
    email = @transaction_message.client_account.email
    subject = email_subject_for_transaction(@current_tenant, @bill)
    transaction_message_pdf = Pdf::PdfTransactionMessage.new(@transaction_message.transaction_date, @transaction_message.client_account, @current_tenant)
    attachments["TransactionMessage_#{@transaction_message.transaction_date}_#{@transaction_message.id}.pdf"] = transaction_message_pdf.render

    if @bill.present?
      bill_transaction_pdf = Print::PrintBill.new(@bill.decorate, @current_tenant, 'for_email')
      attachments["Bill_#{@bill.date}_#{@bill.bill_number}.pdf"] = bill_transaction_pdf.render
    end

    mail(
        from: sender,
        to: email,
        subject: subject,
        template_path: 'smartkhata_mailer'
    )
    @transaction_message.increase_sent_email_count!
    @transaction_message.email_sent!
  end

  def ledger_email(params, ledger_id, current_tenant_id, branch_id, fy_code, email)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    @ledger = Ledger.find_by_id(ledger_id)
    subject = "Your Ledger Report from #{@current_tenant.full_name}"

    ledger_query = Ledgers::Query.new(params, @ledger, branch_id, fy_code)
    report = Reports::Excelsheet::LedgersReport.new(@ledger, params, @current_tenant, ledger_query)
    attachments["#{report.filename}"] = report.file

    mail(
      from: sender,
      to: email,
      subject: subject,
      template_path: 'smartkhata_mailer'
    )
  end

  def bills_email(bill_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    @bill = Bill.find_by_id(bill_id)

    email = @bill.client_account.email
    subject = "Your bill from #{@current_tenant.full_name}"
    bill_pdf = Print::PrintBill.new(@bill.decorate, @current_tenant, 'for_email')
    attachments["Bill_#{@bill.date}_#{@bill.bill_number}.pdf"] = bill_pdf.render
    mail(
      from: sender,
      to: email,
      subject: subject,
      template_path: 'smartkhata_mailer'
    )
  end

  def sender
    "accounts@#{Rails.application.secrets.domain_name}"
  end

  def email_subject_for_transaction(tenant, bill = nil)
    if bill.present?
      "Your transaction message and bill from #{tenant.full_name}"
    else
      "Your transaction message from #{tenant.full_name}"
    end
  end

  def voucher_creation_email_to_client(receipt_transaction_id, current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    receipt_transaction = ReceiptTransaction.find_by_id(receipt_transaction_id)
    @client_account = receipt_transaction.bills.last.client_account

    email = @client_account.email
    subject = "Your receipt from #{@current_tenant.full_name}"

    @settlement = receipt_transaction.voucher.payment_receipts.first

    settlement_pdf = Print::PrintSettlement.new(@settlement.decorate, @current_tenant)
    settlement_pdf.call
    attachments["Receipt_#{@settlement.date_bs}_#{@settlement.settlement_number}.pdf"] = settlement_pdf.render

    mail(
      from: sender,
      to: email,
      subject: subject,
      template_path: 'smartkhata_mailer'
    )
  end
end

