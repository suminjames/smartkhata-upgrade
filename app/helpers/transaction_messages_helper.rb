module TransactionMessagesHelper
  def sms_status_indicator_class(transaction_message)
    css_klass = if transaction_message.can_sms?
                  if transaction_message.sms_sent?
                    'sms-sent'
                  else
                    'sms-unsent'
                  end
                else
                  'sms-cant-send'
                end
    "sms-indicator #{css_klass}"
  end
end
