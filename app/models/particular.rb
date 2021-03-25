# == Schema Information
#
# Table name: particulars
#
#  id                     :integer          not null, primary key
#  opening_balance        :decimal(15, 4)   default(0.0)
#  transaction_type       :integer
#  ledger_type            :integer          default(0)
#  cheque_number          :integer
#  name                   :string
#  description            :string
#  amount                 :decimal(15, 4)   default(0.0)
#  running_blnc           :decimal(15, 4)   default(0.0)
#  additional_bank_id     :integer
#  particular_status      :integer          default(1)
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
#  hide_for_client        :boolean          default(FALSE)
#

class Particular < ApplicationRecord
  # include Auditable
  include CustomDateModule
  include FiscalYearModule
  include ::Models::UpdaterWithBranchFycode
  include ChangesTrackable

  belongs_to :ledger
  belongs_to :voucher
  delegate :bills, :to => :voucher, :allow_nil => true

  # has_and_belongs_to_many :settlements
  has_many :for_dr, -> { dr }, class_name: "ParticularSettlementAssociation"
  has_many :for_cr, -> { cr }, class_name: "ParticularSettlementAssociation"
  has_many :particular_settlement_associations, dependent: :destroy
  has_many :settlements, through: :particular_settlement_associations

  has_many :debit_settlements, through: :for_dr, source: :settlement
  has_many :credit_settlements, through: :for_cr, source: :settlement

  attr_accessor :running_total, :bills_selection, :selected_bill_names, :clear_ledger, :ledger_balance_adjustment, :reverse_transaction

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
  has_many :reversals, -> { reversal }, class_name: "ChequeEntryParticularAssociation"
  has_many :cheque_entry_particular_associations, dependent: :destroy

  has_many :cheque_entries_on_payment, through: :payments, source: :cheque_entry
  has_many :cheque_entries_on_receipt, through: :receipts, source: :cheque_entry
  has_many :cheque_entries_on_reversal, through: :reversals, source: :cheque_entry
  has_many :cheque_entries, through: :cheque_entry_particular_associations

  has_one :nepse_chalan, through: :voucher

  has_one :bank_payment_letter


  # validates_presence_of :ledger_id
  validate :value_date_latest_than_date

  enum transaction_type: [:dr, :cr]
  enum particular_status: [:pending, :complete]
  enum ledger_type: [:general, :has_bank]

  scope :find_by_ledger_ids, lambda { |ledger_ids_arr|
    where(ledger_id: ledger_ids_arr)
  }
  scope :find_by_date_range, -> (date_from, date_to) { where(:transaction_date => date_from.beginning_of_day..date_to.end_of_day) }

  scope :find_by_date, -> (date) { where(:transaction_date => date.beginning_of_day..date.end_of_day) }

  before_validation :process_particular, :assign_default_value_date

  after_commit :calculate_ledger_dailies
  after_commit :recalculate_interest

  def calculate_ledger_dailies
    date_changes = saved_changes["transaction_date"]
    if date_changes.present? && complete?
      dates = date_changes.compact.uniq
      if dates.present?
        dates = dates.map{|date| date.to_s}
        LedgerDailyJob.perform_unique_async(ledger_id, updater_id, fy_code, branch_id, dates)
      end
    end
    # dates = [transaction_date, transaction_date_was].compact.uniq
    # if dates.present?
    #   dates = dates.map{|date| date.to_s}
    #   LedgerDailyJob.perform_later(ledger_id, updater_id, fy_code, branch_id, dates)
    # end
  end


  def value_date_latest_than_date
    # for reverse transaction value date can reflect the bounce date
    if !reverse_transaction && value_date < transaction_date
      errors.add(:value_date, "cant be earlier than transaction date")
    end
  end

  def recalculate_interest
    value_date_changes = saved_changes["value_date"]
    if value_date_changes.present? && complete?
      _value_date = value_date_changes.compact.min
      if (_value_date < Time.current.to_date )
        InterestJob.perform_later(self.ledger_id, _value_date.to_s)
      end
    end

    # if value_date < Time.current.to_date
    #   InterestParticular.calculate_interest(date: value_date, ledger_id: ledger_id)
    #
    #   # in case of date swap we need to calculate interest for both dates
    #   if value_date_was.present? && value_date_was < Time.current.to_date
    #     InterestParticular.calculate_interest(date: value_date_was, ledger_id: ledger_id)
    #   end
    # end
  end


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
    self.fy_code ||= get_fy_code(self.transaction_date)
  end

  def assign_default_value_date
    self.value_date ||= self.transaction_date
  end
end
