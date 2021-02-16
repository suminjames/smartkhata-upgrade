# == Schema Information
#
# Table name: esewa_receipts
#
#  id              :integer          not null, primary key
#  service_charge  :decimal(, )
#  delivery_charge :decimal(, )
#  amount          :decimal(, )
#  tax_amount      :decimal(, )
#  success_url     :string
#  failure_url     :string
#  response_ref    :string
#  response_amount :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

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
  attr_accessor :total_amount, :bill_ids

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
    transaction_id = SecureRandom.hex(10) + self.id.to_s
    transaction_amount = self.total_amount
    transaction_date = Date.today.to_s
    ReceiptTransactions::ReceiptTransactionService.new(self, transaction_id, transaction_date, transaction_amount).call
  end
end
