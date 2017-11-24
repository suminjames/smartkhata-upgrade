set :output, "#{path}/log/cron_log.log"
every 1.day, :at => '10:00 am' do
  runner "SmsMessage.check_for_sms_credit_shortage"
end
