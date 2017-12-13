every 1.day, :at => '05:00 am' do
  runner "SmsMessage.check_for_sms_credit_shortage"
end
