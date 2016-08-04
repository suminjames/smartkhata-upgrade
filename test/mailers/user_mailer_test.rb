require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def setup
    @transaction_message = transaction_messages(:one)
    @bill = Bill.unscoped.find(@transaction_message.bill_id)
    set_fy_code_and_branch_from(@bill, true)
    @tenant = Tenant.first
  end

  test "bill email" do
    # Create the email and store it for further assertions
    email = UserMailer.bill_email(@transaction_message.id, @tenant.id)

    # Send the email, then test that it got queued
    assert_emails(1) { email.deliver_now }

    # Test the body of the sent email contains what we expect it to
    assert_equal ["#{@tenant.name}@danpheinfotech.com"], email.from
    assert_equal [@transaction_message.client_account.email], email.to
    assert_equal "Your bill from #{@tenant.full_name}", email.subject

    # test attachment, no mail body
    assert_equal 1, email.attachments.count
    attachment = email.attachments.first

    assert_equal "Bill_#{@bill.date}_#{@bill.bill_number}.pdf", attachment.filename
    # content_type also includes the filename!?
    assert_contains "application/pdf", attachment.content_type
  end

  test "transaction message email" do
    # Create the email and store it for further assertions
    email = UserMailer.transaction_message_email(@transaction_message.id, @tenant.id)

    # Send the email, then test that it got queued
    assert_emails(1) { email.deliver_now }

    # Test the body of the sent email contains what we expect it to
    assert_equal ["#{@tenant.name}@danpheinfotech.com"], email.from
    assert_equal [@transaction_message.client_account.email], email.to
    assert_equal "Your transaction message from #{@tenant.full_name}", email.subject

    # test attachment, no mail body
    assert_equal 1, email.attachments.count
    attachment = email.attachments.first

    assert_equal "TransactionMessage_#{@transaction_message.transaction_date}_#{@transaction_message.id}.pdf", attachment.filename
    # content_type also includes the filename!?
    assert_contains "application/pdf", attachment.content_type
  end
end
