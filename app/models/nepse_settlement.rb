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

class NepseSettlement < ApplicationRecord
  include Auditable
  enum status: { pending: 0, complete: 1 }
  include ::Models::Updater
  has_many :bills

  def bills_for_payment_letter_list(branch_id)
    # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
    self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount > 0 }
  end

  # since trishakti wants to create cheque for all
  # dont make the payment for sales bills for cases where net amount is less than zero (full closeout cases)
  def bills_for_sales_payment_list(branch_id)
    # self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
    self.bills.by_branch_id(branch_id).to_a.select { |bill| bill.requires_processing? && bill.net_amount > 0 }
    # self.bills.to_a
  end

  scope :purchases, -> { where(type: 'NepsePurchaseSettlement') }
  scope :sales, -> { where(type: 'NepseSaleSettlement') }
  scope :cns, -> { where(type: 'NepseProvisionalSettlement') }

  def self.settlement_types
    %w[NepsePurchaseSettlement NepseSaleSettlement NepseProvisionalSettlement]
  end
end
