# == Schema Information
#
# Table name: bank_accounts
#
#  id                  :integer          not null, primary key
#  account_number      :integer
#  bank_name           :string
#  default_for_payment :boolean
#  default_for_receive :boolean
#  creator_id          :integer
#  updater_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bank_id             :integer
#

class BankAccount < ActiveRecord::Base
  include ::Models::Updater

  before_save :change_default
  before_create :assign_group


  has_many :cheque_entries
  has_one :ledger
  belongs_to :bank
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'


  validates_presence_of :bank_id, :account_number
  accepts_nested_attributes_for :ledger


  # change the default for purchase and sales bank accounts
  # so that the current one becomes the default if opted
  def change_default
    if self.default_for_payment
      bank_accounts = BankAccount.where( :default_for_payment => true)
      bank_accounts = BankAccount.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_payment => false)
    end

    if self.default_for_receive
      bank_accounts = BankAccount.where( :default_for_receipt => true)
      bank_accounts = BankAccount.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_receipt => false)
    end

  end

  def name
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
