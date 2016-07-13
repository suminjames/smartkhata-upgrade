# == Schema Information
#
# Table name: ledger_dailies
#
#  id              :integer          not null, primary key
#  date            :date
#  dr_amount       :decimal(15, 4)   default("0.0")
#  cr_amount       :decimal(15, 4)   default("0.0")
#  opening_balance :decimal(15, 4)   default("0.0")
#  closing_balance :decimal(15, 4)   default("0.0")
#  date_bs         :string
#  fy_code         :integer
#  creator_id      :integer
#  updater_id      :integer
#  ledger_id       :integer
#  branch_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LedgerDaily < ActiveRecord::Base
  include CustomDateModule
  include ::Models::UpdaterWithFyCode

  belongs_to :ledger
  before_save :process_daily_ledger

  def self.opening_balance_of_ledger_dailies(ledger_daily_ids)
    self.where(id: ledger_daily_ids).sum(:opening_balance).to_f
  end

  def self.closing_balance_of_ledger_dailies(ledger_daily_ids)
    self.where(id: ledger_daily_ids).sum(:closing_balance).to_f
  end

  private
  def process_daily_ledger
    self.date_bs ||= ad_to_bs_string(self.date)
  end
end
