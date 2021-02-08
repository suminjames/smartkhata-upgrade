class EsewaPayment < ActiveRecord::Base
  ########################################
  # Constants
  PAYMENT_URL = Rails.env.production? ? "https://esewa.com.np/epay/main" : "https://uat.esewa.com.np/epay/main"
  PAYMENT_VERIFICATION_URL = Rails.env.production? ? "https://esewa.com.np/epay/transrec" : "https://uat.esewa.com.np/epay/transrec"

  ########################################
  # Includes

  ########################################
  # Relationships
  has_many :esewa_transaction_verifications
  has_many :bills

  ########################################
  # Callbacks
  after_create :set_request_sent_time

  ########################################
  # Validations

  ########################################
  # Enums
  enum status: [:success, :fail]

  ########################################
  # Scopes

  ########################################
  # Attributes

  ########################################
  # Delegations

  ########################################
  # Methods
  def set_request_sent_time
    self.update(request_sent_at: Time.now)
  end

  def set_response_received_time
    self.update(response_received_at: Time.now)
  end

  def verification_status
    self.verification_status.status
  end
end