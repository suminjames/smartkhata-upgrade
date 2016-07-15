# == Schema Information
#
# Table name: sales_settlements
#
#  id              :integer          not null, primary key
#  settlement_id   :decimal(18, )
#  status          :integer          default("0")
#  creator_id      :integer
#  updater_id      :integer
#  settlement_date :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#



class SalesSettlement < ActiveRecord::Base
  enum status: [:pending, :complete]
  include ::Models::Updater
  has_many :bills


  def bills_for_payment_letter_list
    self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
  end

  def bills_for_sales_payment_list
    self.bills.to_a.select {|bill| bill.client_account.ledger.closing_balance < 0 && bill.requires_processing?}
  end
end
