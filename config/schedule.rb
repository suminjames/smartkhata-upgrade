set :output, "#{path}/log/cron_log.log"
every 1.minute, :at => '4:30 am' do
  runner "SmsMessage.check_for_sms_credit_shortage"
end