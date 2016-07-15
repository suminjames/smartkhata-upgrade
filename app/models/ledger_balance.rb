# == Schema Information
#
# Table name: ledger_balances
#
#  id              :integer          not null, primary key
#  opening_balance :decimal(15, 4)   default("0.0")
#  closing_balance :decimal(15, 4)   default("0.0")
#  dr_amount       :decimal(15, 4)   default("0.0")
#  cr_amount       :decimal(15, 4)   default("0.0")
#  fy_code         :integer
#  branch_id       :integer
#  creator_id      :integer
#  updater_id      :integer
#  ledger_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LedgerBalance < ActiveRecord::Base
  belongs_to :ledger
  include ::Models::UpdaterWithFyCode
  attr_accessor :opening_balance_type
  before_create :update_closing_balance

  def update_closing_balance
    unless self.opening_balance.blank?
      self.opening_balance = self.opening_balance * -1 if self.opening_balance_type.to_i == Particular.transaction_types['cr']
      self.closing_balance = self.opening_balance
    else
      self.opening_balance = 0
    end
  end
end
