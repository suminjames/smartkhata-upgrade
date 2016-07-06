# == Schema Information
#
# Table name: vouchers
#
#  id               :integer          not null, primary key
#  fy_code          :integer
#  voucher_number   :integer
#  date             :date
#  date_bs          :string
#  desc             :string
#  beneficiary_name :string
#  voucher_type     :integer          default("0")
#  voucher_status   :integer          default("0")
#  creator_id       :integer
#  updater_id       :integer
#  reviewer_id      :integer
#  branch_id        :integer
#  is_payment_bank  :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#


class Voucher < ActiveRecord::Base
  # include FiscalYearModule
  include ::Models::UpdaterWithBranchFycode

  has_many :particulars
  has_many :share_transactions
  has_many :ledgers, :through => :particulars
  has_many :cheque_entries, :through => :particulars

  accepts_nested_attributes_for :particulars
  has_many :settlements
  has_one :nepse_chalan

  has_many :on_creation, -> { on_creation }, class_name: "BillVoucherAssociation"
  has_many :on_settlement, -> { on_settlement }, class_name: "BillVoucherAssociation"
  has_many :bill_voucher_associations
  has_many :bills_on_creation, through: :on_creation, source: :bill
  has_many :bills_on_settlement, through: :on_settlement, source: :bill
  has_many :bills, through: :bill_voucher_associations

  belongs_to :reviewer, class_name: 'User'

  # purchase and sales kept as per the accounting norm
  # however voucher types will be represented as payment and receive
  enum voucher_type: [:journal, :payment, :receipt, :contra]
  enum voucher_status: [:pending, :complete, :rejected]

  before_save :process_voucher
  after_save :assign_cheque

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
      else
        "NA"
    end
  end

  private
  def process_voucher
    fy_code = get_fy_code
    # TODO double check the query for enum
    # rails enum and query not working properly
    last_voucher = Voucher.where(fy_code: fy_code, voucher_type: Voucher.voucher_types[self.voucher_type]).last
    self.voucher_number ||= last_voucher.present? ? last_voucher.voucher_number+1 : 1
    # self.fy_code = fy_code
    self.date = Time.now

  end

  def assign_cheque

    if self.payment?
      cheque_entries = self.cheque_entries.payment.uniq
      particulars = self.particulars.dr

      particulars.each do |particular|
        if particular.cheque_entries_on_payment.size <= 0
          particular.cheque_entries_on_payment << cheque_entries
          particular.save!
        end
      end
      cheque_entries.each do |cheque|
        cheque.beneficiary_name ||= particulars.first.ledger.name
        cheque.save!
      end
    elsif self.receipt?
      cheque_entries = self.cheque_entries.receipt.uniq
      particulars = self.particulars.cr
      particulars.each do |particular|
        if particular.cheque_entries_on_receipt.size <= 0
          particular.cheque_entries_on_receipt << cheque_entries
          particular.save!
        end
      end

      cheque_entries.each do |cheque|
        cheque.beneficiary_name ||= particulars.first.ledger.name
        cheque.save!
      end

    end
  end
end
