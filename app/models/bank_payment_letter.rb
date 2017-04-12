# == Schema Information
#
# Table name: bank_payment_letters
#
#  id                  :integer          not null, primary key
#  settlement_amount   :decimal(15, 4)   default(0.0)
#  fy_code             :integer
#  creator_id          :integer
#  updater_id          :integer
#  bank_account_id     :integer
#  nepse_settlement_id :integer
#  branch_id           :integer
#  voucher_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  letter_status       :integer          default(0)
#  reviewer_id         :integer          default(0)
#

class BankPaymentLetter < ActiveRecord::Base

  include Auditable

  belongs_to :nepse_settlement
  belongs_to :branch
  belongs_to :voucher
  belongs_to :bank_account
  has_many :particulars
  delegate :bills, :to => :voucher, :allow_nil => true

  enum letter_status: [:pending, :approved, :cancelled]
end
