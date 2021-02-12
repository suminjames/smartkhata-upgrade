# == Schema Information
#
# Table name: nchl_payments
#
#  id           :integer          not null, primary key
#  reference_id :string
#  remarks      :text
#  particular   :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  token        :text
#

class NchlPayment < ActiveRecord::Base

  ########################################
  # Constants
  PAYMENT_VERIFICATION_URL = Rails.application.secrets.nchl_payment_verification_url
  PAYMENT_URL              = Rails.application.secrets.nchl_payment_url
  MerchantId               = Rails.application.secrets.nchl_merchant_id
  AppId                    = Rails.application.secrets.nchl_app_id
  AppName                  = Rails.application.secrets.nchl_app_name

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
  attr_accessor :amount, :bill_ids, :transaction_id, :transaction_date

  ########################################
  # Delegations

  ########################################
  # Methods

  def save_receipt_transaction
    receipt_transaction = self.build_receipt_transaction(transaction_id:   self.transaction_id,
                                                         transaction_date: self.transaction_date,
                                                         request_sent_at:  Time.now,
                                                         amount:           self.amount,
                                                         bill_ids:         self.bill_ids)
    unless receipt_transaction.save
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
