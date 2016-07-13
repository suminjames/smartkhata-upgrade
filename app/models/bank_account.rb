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

class BankAccount < ActiveRecord::Base
  include ::Models::Updater
  attr_reader :bank_account_name
  before_save :change_default
  before_create :assign_group

  has_many :cheque_entries
  has_one :ledger
  belongs_to :bank

  # alphanumeric account number with atleast a single digit
  validates :account_number, uniqueness: true, format: {with: ACCOUNT_NUMBER_REGEX, message: 'should be numeric or alphanumeric'}
  validates_presence_of :bank, :account_number
  accepts_nested_attributes_for :ledger

  # change the default for purchase and sales bank accounts
  # so that the current one becomes the default if opted
  def change_default
    if self.default_for_payment
      bank_accounts = BankAccount.where(:default_for_payment => true)
      bank_accounts = BankAccount.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_payment => false)
    end

    if self.default_for_receipt
      bank_accounts = BankAccount.where(:default_for_receipt => true)
      bank_accounts = BankAccount.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_receipt => false)
    end

  end

  def self.default_for_payment
    BankAccount.where(:default_for_payment => true).first
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
  def assign_group

    group = Group.find_by(name: "Current Assets")
    group.ledgers << self.ledger
  end
end
