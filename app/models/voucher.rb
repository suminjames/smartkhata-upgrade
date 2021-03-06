# == Schema Information
#
# Table name: vouchers
#
#  id                     :integer          not null, primary key
#  fy_code                :integer
#  voucher_number         :integer
#  date                   :date
#  date_bs                :string
#  desc                   :string
#  beneficiary_name       :string
#  voucher_type           :integer          default(0)
#  voucher_status         :integer          default(0)
#  creator_id             :integer
#  updater_id             :integer
#  reviewer_id            :integer
#  branch_id              :integer
#  is_payment_bank        :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_date             :date
#  receipt_transaction_id :integer
#

class Voucher < ApplicationRecord
  include Auditable
  # include FiscalYearModule
  include ::Models::UpdaterWithBranchFycode
  include CustomDateModule

  attr_accessor :skip_cheque_assign, :skip_number_assign, :current_tenant, :value_date_bs

  # purchase and sales kept as per the accounting norm
  # however voucher types will be represented as payment and receive
  enum voucher_type: [:journal, :payment, :receipt, :contra, :payment_cash, :receipt_cash, :payment_bank, :receipt_bank, :receipt_bank_deposit, :receipt_esewa, :receipt_nchl]
  enum voucher_status: [:pending, :complete, :rejected, :reversed]

  ########################################
  # Callbacks

  before_save :process_voucher
  # before_validation :validate_fy_code
  after_save :assign_cheque, unless: :skip_cheque_assign

  ########################################
  # Relationships
  has_many :particulars
  has_many :share_transactions
  has_many :ledgers, through: :particulars
  has_many :cheque_entries, through: :particulars
  accepts_nested_attributes_for :particulars
  belongs_to :receipt_transaction, optional: true

  # defunct assumed
  has_many :settlements, dependent: :destroy
  # this might be the one in use
  has_many :payment_receipts, through: :particulars, source: :settlements
  has_one :nepse_chalan
  has_many :bill_voucher_associations, dependent: :destroy
  has_many :bills_on_creation,
           -> { where(bill_voucher_associations: { association_type: :on_creation }) },
           through: :bill_voucher_associations,
           source: :bill
  has_many :bills_on_settlement,
           -> { where(bill_voucher_associations: { association_type: :on_settlement }) },
           through: :bill_voucher_associations,
           source: :bill
  has_many :bills, through: :bill_voucher_associations
  belongs_to :reviewer, class_name: 'User', optional: true

  has_one :mandala_voucher, class_name: "Mandala::Voucher"
  ########################################
  # Validations
  # validate :date_valid_for_fy_code?
  validates :voucher_number, uniqueness: { scope: %i[voucher_type fy_code], allow_nil: true }

  # validate :value_date_after_date

  ########################################
  # scopes
  scope :by_branch_fy_code, lambda { |branch_id, fy_code|
    if branch_id.zero?
      where(fy_code: fy_code)
    else
      where(branch_id: branch_id, fy_code: fy_code)
    end
  }

  def voucher_code
    case self.voucher_type.to_sym
      when :journal
        "JVR"
      when :payment
        "PMT"
      when :receipt
        "RCV"
      when :contra
        "CVR"
      when :payment_cash
        "PVR"
      when :receipt_cash
        "RCP"
      when :payment_bank
        "PVB"
      when :receipt_bank
        "RCB"
      when :receipt_bank_deposit
        "CDB"
      when :receipt_esewa
        "RCE"
      when :receipt_nchl
        "RCN"
      else
        "NA"
    end
  end

  # implemented the various types of vouchers
  # payment and receipt are for legacy purpose
  def is_payment_receipt?
    self.payment? || self.receipt? || self.payment_cash? || self.receipt_cash? || self.receipt_bank? || self.payment_bank? || self.receipt_bank_deposit?
  end

  def is_payment?
    self.payment? || self.payment_cash? || self.payment_bank?
  end

  def is_receipt?
    self.receipt? || self.receipt_cash? || self.receipt_bank? || self.receipt_bank_deposit?
  end

  def is_bank_related_receipt?
    self.receipt? || self.receipt_bank? || self.receipt_bank_deposit?
  end

  def is_bank_related_payment?
    self.payment? || self.payment_bank?
  end

  def is_receipt_transaction?
    self.receipt_esewa? || self.receipt_nchl?
  end


  def map_payment_receipt_to_new_types
    if self.receipt? || self.payment?
      self.voucher_type = if self.receipt?
                            if self.cheque_entries.count.positive?
                              :receipt_bank
                            else
                              :receipt_cash
                            end
                          else
                            if self.cheque_entries.count.positive?
                              :payment_bank
                            else
                              :payment_cash
                            end
                          end
    end
  end

  def has_incorrect_fy_code?
    true_fy_code = get_fy_code(self.date)
    return true if true_fy_code != self.fy_code

    false
  end

  private

  def process_voucher
    self.date ||= Time.now
    self.date_bs ||= ad_to_bs_string(self.date)
    self.value_date ||= self.date
    self.value_date ||= bs_to_ad(self.value_date_bs)
    fy_code = get_fy_code(self.date)

    # TODO double check the query for enum
    # rails enum and query not working properly
    unless skip_number_assign
      last_voucher = Voucher.unscoped.where(fy_code: fy_code, voucher_type: Voucher.voucher_types[self.voucher_type]).where.not(voucher_number: nil).order(voucher_number: :desc).first
      # faced voucher_number uniqueness validation error.
      # scenario to create:
      # when first voucher is created as receipt, while saving it changes to receipt_bank or receipt_cash(create.rb line 525) and voucher_number is 1
      # again when another voucher is created as receipt, last_voucher is empty as last voucher type is saved as receipt_bank or receipt_cash
      # so second voucher also get voucher number 1
      # due to which uniqueness validation error is generated
      self.voucher_number ||= last_voucher.present? ? (last_voucher.voucher_number + 1) : 1
    end
    self.fy_code = fy_code
  end

  #
  # If this voucher is payment, assign the cheques to debited particular(s) of the voucher.
  # If this voucher is receipt, assign the cheques to credited particular(s) of the voucher.
  #
  def assign_cheque
    if self.is_payment?
      cheque_entries = self.cheque_entries.payment.uniq
      dr_particulars = self.particulars.select(&:dr?)

      dr_particulars.each do |particular|
        if particular.cheque_entries_on_payment.size <= 0
          particular.cheque_entries_on_payment << cheque_entries
          particular.save!
        end
      end

      cheque_entries.each do |cheque|
        if dr_particulars.size > 0

          beneficiary_name = if dr_particulars.first.has_bank?
                               current_tenant.full_name
                             else
                               dr_particulars.first.ledger.name
                             end
        end
        cheque.beneficiary_name ||= beneficiary_name
        cheque.save!
      end
      # Check to see if transaction between internal banks.
      # If so, add beneficiary names to the other as current tenant's full name.
      cr_particulars = self.particulars.select(&:cr?)
      if dr_particulars.size > 0 && cr_particulars.size > 0 && dr_particulars.first.has_bank? && cr_particulars.first.has_bank?
        cheque_entries = self.cheque_entries.receipt.uniq
        cheque_entries.each do |cheque|
          beneficiary_name = if cr_particulars.first.has_bank?
                               current_tenant.full_name
                             else
                               cr_particulars.first.ledger.name
                             end
          cheque.beneficiary_name ||= beneficiary_name
          cheque.save!
        end
      end
    elsif self.is_receipt?
      cheque_entries = self.cheque_entries.receipt.uniq
      particulars = self.particulars.cr
      particulars.each do |particular|
        if particular.cheque_entries_on_receipt.size <= 0
          particular.cheque_entries_on_receipt << cheque_entries
          particular.save!
        end
      end

      cheque_entries.each do |cheque|
        beneficiary_name = if particulars.first.has_bank?
                             current_tenant.full_name
                           else
                             particulars.first.ledger.name
                           end
        cheque.beneficiary_name ||= beneficiary_name
        cheque.save!
      end

    end
  end

  # def value_date_after_date
  #   if value_date.present? && value_date < date
  #     errors.add(:value_date, "can not be of past date")
  #   end
  # end
end
