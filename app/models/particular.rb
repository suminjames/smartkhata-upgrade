# == Schema Information
#
# Table name: particulars
#
#  id                     :integer          not null, primary key
#  opening_balance        :decimal(15, 4)   default("0")
#  transaction_type       :integer
#  ledger_type            :integer          default("0")
#  cheque_number          :integer
#  name                   :string
#  description            :string
#  amount                 :decimal(15, 4)   default("0")
#  running_blnc           :decimal(15, 4)   default("0")
#  additional_bank_id     :integer
#  particular_status      :integer          default("1")
#  date_bs                :string
#  creator_id             :integer
#  updater_id             :integer
#  fy_code                :integer
#  branch_id              :integer
#  transaction_date       :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ledger_id              :integer
#  voucher_id             :integer
#  bank_payment_letter_id :integer
#  hide_for_client        :boolean          default("false")
#

class Particular < ActiveRecord::Base
  include CustomDateModule
  include ::Models::UpdaterWithBranchFycode

  belongs_to :ledger
  belongs_to :voucher
  delegate :bills, :to => :voucher, :allow_nil => true

  attr_accessor :running_total

  # get the particulars with running total
  # records: collection of particular
  def self.with_running_total(records, opening_balance = 0.0)
    total = 0.0
    records.map do |w|
      amount = w.cr? ? (-1 * w.amount) : w.amount
      total += (amount + opening_balance)
      # we need to add the opening blnc only once
      opening_balance = 0.0
      w.running_total = total
    end
    records
  end


  # belongs_to :receipt
  has_many :cheque_entries

  # for many to many relation between cheque and the particulars.
  # a cheque can pay/recieve for multiple particulars.
  has_many :payments, -> { payment }, class_name: "ChequeEntryParticularAssociation"
  has_many :receipts, -> { receipt }, class_name: "ChequeEntryParticularAssociation"
  has_many :cheque_entry_particular_associations

  has_many :cheque_entries_on_payment, through: :payments, source: :cheque_entry
  has_many :cheque_entries_on_receipt, through: :receipts, source: :cheque_entry
  has_many :cheque_entries, through: :cheque_entry_particular_associations

  has_one :nepse_chalan, through: :voucher

  has_one :bank_payment_letter


  validates_presence_of :ledger_id
  enum transaction_type: [:dr, :cr]
  enum particular_status: [:pending, :complete]
  enum ledger_type: [:general, :has_bank]

  scope :find_by_date_range, -> (date_from, date_to) { where(
      :transaction_date => date_from.beginning_of_day..date_to.end_of_day) }

  before_save :process_particular

  def get_description
    if self.description.present?
      self.description
    elsif self.name.present?
      self.name
    else
      "as per details"
    end
  end

  private
  def process_particular
    self.transaction_date ||= Time.now
    self.date_bs ||= ad_to_bs_string(self.transaction_date)
  end

end
