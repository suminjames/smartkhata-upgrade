# == Schema Information
#
# Table name: bank_accounts
#
#  id                  :integer          not null, primary key
#  account_number      :string
#  bank_name           :string
#  default_for_payment :boolean
#  default_for_receipt :boolean
#  creator_id          :integer
#  updater_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bank_id             :integer
#  branch_id           :integer
#  bank_branch         :string
#  address             :text
#  contact_no          :string
#

class BankAccount < ApplicationRecord
  include Auditable
  include ::Models::UpdaterWithBranch
  attr_reader :bank_account_name
  # attr_accessor :opening_balance, :opening_balance_type
  before_save :change_default
  after_save :update_ledger_name
  # before_create :assign_group

  # default scope for branch account
  # default_scope do
  #   if UserSession.selected_branch_id != 0
  #     where(branch_id: UserSession.selected_branch_id)
  #   end
  # end

  has_many :cheque_entries
  has_one :ledger
  belongs_to :bank

  # alphanumeric account number with atleast a single digit
  validates :account_number, uniqueness: true, format: { with: ACCOUNT_NUMBER_REGEX, message: 'should be numeric or alphanumeric' }
  validates :account_number, :bank_branch, presence: true
  accepts_nested_attributes_for :ledger

  scope :by_default_esewa_receipt, -> { where(:default_for_esewa_receipt => true) }
  scope :by_default_nchl_receipt, -> { where(:default_for_nchl_receipt => true)}


  def test_dummy
    raise SmartKhataError
  end

  # change the default for purchase and sales bank accounts
  # so that the current one becomes the default if opted
  def change_default
    BankAccount.by_branch_id(branch_id).where.not(id: self.id).update_all(default_for_payment: false) if self.default_for_payment

    BankAccount.by_branch_id(branch_id).where.not(id: self.id).update_all(default_for_receipt: false) if self.default_for_receipt
  end

  def self.default_for_payment(branch_id)
    BankAccount.by_branch_id(branch_id).where(default_for_payment: true).first
  end

  def self.default_receipt_account(branch_id)
    default_for_receipt_bank_account_in_branch = BankAccount.by_branch_id(branch_id).where(default_for_receipt: true).first
    # Check for availability of default bank accounts for payment and receipt in the current branch.
    # If not available in the current branch, resort to using whichever is available from all available branches.
    default_for_receipt_bank_account_in_branch.presence || BankAccount.where(default_for_receipt: true).first
  end

  def name
    "#{self.bank.bank_code}-#{self.account_number}"
  end

  def bank_account_name
    "#{self.bank.bank_code}-#{self.account_number}"
  end

  def bank_name
    self.bank.name
  end

  def get_current_assets_group
    Group.find_by(name: "Current Assets").id
  end

  def save_custom(fy_code, branch_id, current_user_id)
    _group_id = get_current_assets_group
    _bank = Bank.find_by(id: self.bank_id)
    self.ledger.current_user_id = current_user_id
    if _bank.present?
      self.ledger.name = ledger_name
      self.ledger.group_id = _group_id
      self.bank_name = _bank.name
      begin
        ActiveRecord::Base.transaction do
          if self.save
            LedgerBalance.update_or_create_org_balance(self.ledger.id, fy_code, current_user_id)
            return true
          end
        end
      rescue ActiveRecord::RecordNotUnique => e
        self.errors.add(:base, "Please make sure one entry per branch")
      end
    end
    false
  end

  def ledger_name
    "Bank:" + bank.name + "(#{account_number})"
  end

  def update_ledger_name
    self.ledger.update_columns(name: ledger_name)
  end

  # assign the ledgers to group name bank accounts
  # def assign_group
  #   group = Group.find_by(name: "Current Assets")
  #   group.ledgers << self.ledger
  # end
end
