module EsewaReceiptsHelper
  def get_success_url
    get_base_url + 'success/?q=su'
  end

  def get_failure_url
    get_base_url + 'failure/?q=fu'
  end

  def get_esewa_security_code
    Rails.application.secrets.esewa_security_code
  end

  def zero_if_nil(amt)
    amt || 0
  end

  def get_base_url
    Rails.application.secrets.epay_redirection_url+'/receipt_transactions/'
  end

  def get_total_amount payment
    payment.amount + zero_if_nil(payment.service_charge) + zero_if_nil(payment.tax_amount) + zero_if_nil(payment.delivery_charge)
  end
end
