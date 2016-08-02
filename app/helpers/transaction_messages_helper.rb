module TransactionMessagesHelper

  def sms_status_indicator_class(transaction_message)
    if transaction_message.can_sms?
      if transaction_message.sms_sent?
        css_klass = 'sms-sent'
      else
        css_klass = 'sms-unsent'
      end
    else
      css_klass = 'sms-cant-send'
    end
    "sms-indicator #{css_klass}"
  end

end
