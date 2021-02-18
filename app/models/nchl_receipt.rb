# == Schema Information
#
# Table name: nchl_receipts
#
#  id           :integer          not null, primary key
#  reference_id :string
#  remarks      :text
#  particular   :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  token        :text
#

class NchlReceipt < ActiveRecord::Base
  include SignTokenModule

  ########################################
  # Constants
  PAYMENT_VERIFICATION_URL = Rails.application.secrets.nchl_receipt_verification_url.freeze
  PAYMENT_URL              = Rails.application.secrets.nchl_receipt_url.freeze
  MERCHANTID               = Rails.application.secrets.nchl_merchant_id.freeze
  APPID                    = Rails.application.secrets.nchl_app_id.freeze
  APPNAME                  = Rails.application.secrets.nchl_app_name.freeze

  ########################################
  # Includes

  ########################################
  # Relationships
  has_one :receipt_transaction, as: :receivable

  ########################################
  # Callbacks
  before_validation :build_payload
  after_create :save_receipt_transaction

  ########################################
  # Validations

  ########################################
  # Enums

  ########################################
  # Scopes

  ########################################
  # Attributes
  attr_accessor :amount, :bill_ids, :transaction_id, :transaction_date, :transaction_currency, :merchant_id, :app_name, :app_id

  ########################################
  # Delegations

  ########################################
  # Methods

  def save_receipt_transaction
    transaction_id = self.transaction_id
    # here we are getting amount as paisa cause connect ips api needs amount to be passed as paisa
    # so converting it into rs while saving into database
    transaction_amount = (self.amount.to_i / 100).to_s
    transaction_date = self.transaction_date
    ReceiptTransactions::ReceiptTransactionService.new(self, transaction_id, transaction_date, transaction_amount).call
  end

  def build_payload
    self.transaction_id,
      self.reference_id,
      self.remarks,
      self.particular,
      self.transaction_date,
      self.transaction_currency,
      self.merchant_id,
      self.app_id,
      self.app_name = payload_values

    data       = "MERCHANTID=#{MERCHANTID},APPID=#{APPID},APPNAME=#{APPNAME},TXNID=#{self.transaction_id},TXNDATE=#{self.transaction_date},TXNCRNCY=#{self.transaction_currency},TXNAMT=#{self.amount},REFERENCEID=#{self.reference_id},REMARKS=#{self.remarks},PARTICULARS=#{self.particular},TOKEN=TOKEN"
    self.token = get_signed_token(data)
  end

  def payload_values
    transaction_id = SecureRandom.hex(10)
    return transaction_id,
      transaction_id,
      self.bill_ids.join(','), '', Date.today.to_s, 'NPR',
      MERCHANTID, APPID, APPNAME
  end
end
