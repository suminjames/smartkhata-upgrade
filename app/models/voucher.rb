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
#  voucher_type     :integer          default(0)
#  voucher_status   :integer          default(0)
#  creator_id       :integer
#  updater_id       :integer
#  reviewer_id      :integer
#  branch_id        :integer
#  is_payment_bank  :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Voucher < ActiveRecord::Base
  include Auditable
  # include FiscalYearModule
  include ::Models::UpdaterWithBranchFycode
  include CustomDateModule

  # purchase and sales kept as per the accounting norm
  # however voucher types will be represented as payment and receive
  enum voucher_type: [:journal, :payment, :receipt, :contra]
  enum voucher_status: [:pending, :complete, :rejected, :reversed]

  ########################################
  # Callbacks

  before_save :process_voucher
  after_save :assign_cheque

  ########################################
  # Relationships
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

  ########################################
  # Validations
  # validate :date_valid_for_fy_code?

  ########################################
  # scopes


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

  # def date_valid_for_fy_code?
  #   errors.add :date, "Fuck you Asshole" unless date_valid_for_fy_code(self.fy_code, self.date)
  # end

  private
  def process_voucher
    self.date ||= Time.now
    self.date_bs ||= ad_to_bs_string(self.date)
    fy_code = get_fy_code(self.date)
    # TODO double check the query for enum
    # rails enum and query not working properly
    last_voucher = Voucher.unscoped.where(fy_code: fy_code, voucher_type: Voucher.voucher_types[self.voucher_type]).last
    self.voucher_number ||= last_voucher.present? ? last_voucher.voucher_number+1 : 1
    self.fy_code = fy_code
  end

  #
  # If this voucher is payment, assign the cheques to debited particular(s) of the voucher.
  # If this voucher is receipt, assign the cheques to credited particular(s) of the voucher.
  #
  def assign_cheque

    if self.payment?
      cheque_entries = self.cheque_entries.payment.uniq
      dr_particulars = self.particulars.select{ |x| x.dr? }
      dr_particulars.each do |particular|
        if particular.cheque_entries_on_payment.size <= 0
          particular.cheque_entries_on_payment << cheque_entries
          particular.save!
        end
      end

      cheque_entries.each do |cheque|
        if dr_particulars.size > 0
          if dr_particulars.first.has_bank?
            beneficiary_name = UserSession.tenant.full_name
          else
            beneficiary_name = dr_particulars.first.ledger.name
          end
        end
        cheque.beneficiary_name ||= beneficiary_name
        cheque.save!
      end
      # Check to see if transaction between internal banks.
      # If so, add beneficiary names to both as current tenant's full name.
      cr_particulars = self.particulars.select{ |x| x.cr? }
      if dr_particulars.size > 0 && cr_particulars.size > 0 && dr_particulars.first.has_bank? && cr_particulars.first.has_bank?
        cheque_entries = self.cheque_entries.receipt.uniq
        cheque_entries.each do |cheque|
          if cr_particulars.first.has_bank?
            beneficiary_name = UserSession.tenant.full_name
          else
            beneficiary_name = cr_particulars.first.ledger.name
          end
          cheque.beneficiary_name ||= beneficiary_name
          cheque.save!
        end
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
        if particulars.first.has_bank?
          beneficiary_name = UserSession.tenant.full_name
        else
          beneficiary_name = particulars.first.ledger.name
        end
        cheque.beneficiary_name ||= beneficiary_name
        cheque.save!
      end

    end
  end
end
