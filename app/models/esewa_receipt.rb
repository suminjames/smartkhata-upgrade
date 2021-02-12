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
  PAYMENT_URL              = Rails.application.secrets.esewa_receipt_url
  PAYMENT_VERIFICATION_URL = Rails.application.secrets.esewa_receipt_verification_url

  ########################################
  # Includes

  ########################################
  # Relationships
  has_one :receipt_transaction, as: :receivable

  ########################################
  # Callbacks
  after_create :save_receipt_transaction

  ########################################
  # Validations

  ########################################
  # Enums

  ########################################
  # Scopes

  ########################################
  # Attributes
  attr_accessor :amount, :bill_ids

  ########################################
  # Delegations

  ########################################
  # Methods
  def set_response_ref(ref)
    self.update(response_ref: ref)
  end

  def set_response_amount(amt)
    self.update(response_amount: amt)
  end

  def get_transaction_id
    self.receipt_transaction.transaction_id
  end

  def save_receipt_transaction
    receipt_transaction = self.build_receipt_transaction(transaction_id:   SecureRandom.hex(16),
                                                         transaction_date: Date.today.to_s,
                                                         request_sent_at:  Time.now,
                                                         amount:           self.amount,
                                                         bill_ids:         self.bill_ids)
    unless receipt_transaction.save
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
