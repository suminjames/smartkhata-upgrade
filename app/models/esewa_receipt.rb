# == Schema Information
#
# Table name: esewa_receipts
#
#  id              :integer          not null, primary key
#  service_charge  :decimal(, )
#  delivery_charge :decimal(, )
#  tax_amount      :decimal(, )
#  success_url     :string
#  failure_url     :string
#  response_ref    :string
#  response_amount :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null

class EsewaReceipt < ActiveRecord::Base

  ########################################
  # Constants
  PAYMENT_URL              = Rails.application.secrets.esewa_receipt_url.freeze
  PAYMENT_VERIFICATION_URL = Rails.application.secrets.esewa_receipt_verification_url.freeze

  ########################################
  # Includes

  ########################################
  # Relationships
  has_one :receipt_transaction, as: :receivable

  ########################################
  # Callbacks
  after_create :save_receipt_transaction, :set_failure_url

  ########################################
  # Validations

  ########################################
  # Enums

  ########################################
  # Scopes

  ########################################
  # Attributes
  attr_accessor :total_amount, :bill_ids, :request_base_url

  ########################################
  # Delegations
  delegate :transaction_id, to: :receipt_transaction

  ########################################
  # Methods
  def set_response_ref_and_amt(ref, amt)
    self.update(response_ref: ref, response_amount: amt)
  end

  def validation_amount_mismatched?
    self.receipt_transaction.amount == self.response_amount
  end

  def set_failure_url
    self.failure_url = self.failure_url + "&oid=#{self.transaction_id}"
  end

  def save_receipt_transaction
    receipt_transaction = self.build_receipt_transaction(transaction_id:   SecureRandom.hex(10) + self.id.to_s,
                                                         transaction_date: Date.today.to_s,
                                                         request_sent_at:  Time.now,
                                                         amount:           self.total_amount,
                                                         bill_ids:         self.bill_ids)
    unless receipt_transaction.save
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
