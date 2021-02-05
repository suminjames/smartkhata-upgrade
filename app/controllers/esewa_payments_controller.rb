require 'net/http'

class EsewaPaymentsController < VisitorsController
  before_action :set_esewa_payment, only: [:show, :edit, :update, :destroy]

  def index
    @esewa_payments = EsewaPayment.all
  end

  def create
    @esewa_payment = EsewaPayment.new(esewa_payment_params)

    @esewa_payment.success_url  = get_success_url
    @esewa_payment.failure_url  = get_failure_url

    if @esewa_payment.save
      # response = initiate_payment @esewa_payment
      render json: {payment: @esewa_payment, security_code: get_esewa_security_code}
    else
      render json: {msg: 'cannot save payment record'}
    end
  end

  def success

  end

  def failure

  end

  private

  def set_esewa_payment
    @esewa_payment = EsewaPayment.find(params[:id])
  end

  def esewa_payment_params
    params.permit(:amount, :service_charge, :delivery_charge, :tax_amount, :total_amount, bill_ids: [])
  end


  def get_url
    Rails.env.production? ? "https://esewa.com.np/epay/main" : "https://uat.esewa.com.np/epay/main"
  end

  def get_success_url
    'http://merchant.com.np/page/esewa_payment_success?q=su'
    request.base_url + '/esewa_payments/success/?q=su'
  end

  def get_failure_url
    'http://merchant.com.np/page/esewa_payment_failed?q=fu'
    request.base_url + '/esewa_payments/failure/?q=fu'
  end

  def get_total_amount payment
    payment.amount + zero_if_nil(payment.service_charge) + zero_if_nil(payment.tax_amount) + zero_if_nil(payment.delivery_charge)
  end

  def zero_if_nil(amt)
    amt || 0
  end

  def get_esewa_security_code
    Rails.application.secrets.esewa_security_code
  end

  def get_parameters payment
    {
        'amt':   payment.amount.to_i,
        'pdc':   zero_if_nil(payment.tax_amount),
        'psc':   zero_if_nil(payment.service_charge),
        'txAmt': zero_if_nil(payment.tax_amount),
        'tAmt':  payment.total_amount.to_i,
        'pid':   payment.id,
        'scd':   get_esewa_security_code,
        'su':    get_success_url,
        'fu':    get_failure_url,
    }
  end

  def initiate_payment payment
    uri                     = URI.parse(get_url)
    # request                 = Net::HTTP::Post.new(uri)
    # request["Content-Type"] = "application/json"
    parameters = get_payment_parameters payment
    response = Net::HTTP.post_form(uri, parameters)

    # request.body            = parameters.to_json
    # response                = Net::HTTP.start(uri.hostname, uri.port) do |http|
    #   http.request(request)
    # end
    # JSON.parse(response.body)

  end


end
