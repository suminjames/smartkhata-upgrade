# == Schema Information
#
# Table name: receipt_transactions
#
#  id                              :integer          not null, primary key
#  amount                          :decimal(, )
#  status                          :integer
#  transaction_id                  :string
#  request_sent_at                 :datetime
#  response_received_at            :datetime
#  validation_request_sent_at      :datetime
#  validation_response_received_at :datetime
#  validation_response_code        :integer
#  transaction_date                :date
#  receivable_id                   :integer
#  receivable_type                 :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class ReceiptTransaction < ActiveRecord::Base

  ########################################
  # Constants

  ########################################
  # Includes

  ########################################
  # Relationships
  belongs_to :receivable, polymorphic: true
  has_and_belongs_to_many :bills
  has_one :voucher

  ########################################
  # Callbacks

  ########################################
  # Validations
  validates :receivable_id, :receivable_type, presence: true
  validates_uniqueness_of :transaction_id

  ########################################
  # Enums
  enum status: { success: 0, failure: 1, fraudulent: 2, unprocessed_verification: 3, unprocessed_voucher: 4 }

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

  def set_validation_request_sent_at
    self.update(validation_request_sent_at: Time.now)
  end

  def set_failure_response
    self.update(response_received_at: Time.now, status: 'failure')
  end

  def set_validation_response(code)
    self.update(validation_response_code: code, validation_response_received_at: Time.now)
  end

  def nchl?
    self.receivable_type == "NchlReceipt"
  end

  def esewa?
    self.receivable_type == "EsewaReceipt"
  end

  def particulars
    bills = Bill.where(id: self.bill_ids)
    bill_number = bills.select(:fy_code,:bill_number).map{|x| "#{x.fy_code}-#{x.bill_number}"}.join(',')
    "Settled for Bill No:#{bill_number}-#{particulars_identifier}/ACXFR:#{transaction_id}:#{bills.first&.client_account&.name}"
  end

  def particulars_identifier
    nchl? ? 'CIPS' : 'ESEWA'
  end
end
