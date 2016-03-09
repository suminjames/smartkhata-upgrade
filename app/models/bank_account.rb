class BankAccount < ActiveRecord::Base
  has_many :cheque_entries
  has_one :ledger
  validates_presence_of :name, :account_number
  before_save :change_default
  before_create :assign_group
  accepts_nested_attributes_for :ledger

  # change the default for purchase and sales bank accounts
  # so that the current one becomes the default if opted
  def change_default
    if self.default_for_purchase
      bank_accounts = BankAccount.where( :default_for_purchase => true)
      bank_accounts = BankAccount.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_purchase => false)
    end

    if self.default_for_sales
      bank_accounts = BankAccount.where( :default_for_sales => true)
      bank_accounts = BankAccount.where.not(:id => self.id)
      bank_accounts.update_all(:default_for_sales => false)
    end

  end


  # assign the ledgers to group name bank accounts
  def assign_group
    group = Group.find_by(name: "Current Assets")
    group.ledgers << self.ledger
  end
end
