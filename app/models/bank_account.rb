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
#

class BankAccount < ActiveRecord::Base
  include ::Models::UpdaterWithBranch
  attr_reader :bank_account_name
  # attr_accessor :opening_balance, :opening_balance_type
  before_save :change_default
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
  validates :account_number, uniqueness: true, format: {with: ACCOUNT_NUMBER_REGEX, message: 'should be numeric or alphanumeric'}
  validates_presence_of :bank, :account_number, :bank_branch
  accepts_nested_attributes_for :ledger

  # change the default for purchase and sales bank accounts
  # so that the current one becomes the default if opted
  def change_default
    debugger
    if self.default_for_payment
      bank_accounts = BankAccount.by_branch_id.where(:default_for_payment => true)
      bank_accounts = BankAccount.by_branch_id.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_payment => false)
    end

    if self.default_for_receipt
      bank_accounts = BankAccount.by_branch_id.where(:default_for_receipt => true)
      bank_accounts = BankAccount.by_branch_id.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_receipt => false)
    end

  end

  def self.default_for_payment
    BankAccount.by_branch_id.where(:default_for_payment => true).first
  end

  def name
    "#{self.bank.bank_code }-#{self.account_number}"
  end

  def bank_account_name
    "#{self.bank.bank_code }-#{self.account_number}"
  end

  def bank_name
    "#{self.bank.name}"
  end

  # assign the ledgers to group name bank accounts
  # def assign_group
  #   group = Group.find_by(name: "Current Assets")
  #   group.ledgers << self.ledger
  # end
end
