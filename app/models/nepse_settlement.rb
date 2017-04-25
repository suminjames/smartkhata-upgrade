# == Schema Information
#
# Table name: nepse_settlements
#
#  id              :integer          not null, primary key
#  settlement_id   :decimal(18, )
#  status          :integer          default(0)
#  creator_id      :integer
#  updater_id      :integer
#  settlement_date :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string
#

class NepseSettlement < ActiveRecord::Base
  include Auditable
  enum status: [:pending, :complete]
  include ::Models::Updater
  has_many :bills

  def bills_for_payment_letter_list
    # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
    self.bills.to_a.select {|bill| bill.requires_processing?}
  end

  # since trishakti wants to create cheque for all
  def bills_for_sales_payment_list
    # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
    self.bills.to_a.select {|bill| bill.requires_processing?}
    # self.bills.to_a
  end

  scope :purchases, -> { where(type: 'NepsePurchaseSettlement') }
  scope :sales, -> { where(type: 'NepseSaleSettlement') }

  def self.settlement_types
    %w(NepsePurchaseSettlement NepseSaleSettlement)
  end
end
  