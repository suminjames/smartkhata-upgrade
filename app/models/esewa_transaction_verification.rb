class EsewaTransactionVerification < ActiveRecord::Base
  ########################################
  # Constants

  ########################################
  # Includes

  ########################################
  # Relationships
  belongs_to :esewa_payment

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
    self.request_sent_at = Time.now
  end

  def set_response_received_time
    self.response_received_at = Time.now
  end

  def response_status
    self.status
  end
end
