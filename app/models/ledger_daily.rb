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

# Maintains the most up-to-date(for each day) ledger attribute for the given branch_id.
#  If branch_id is nil, the organisation ledger is being referred. This organisation ledger is already up-to-moment with
#  its branches' ledger daily attributes.
class LedgerDaily < ActiveRecord::Base
  include CustomDateModule
  include ::Models::UpdaterWithFyCode

  belongs_to :ledger
  before_save :process_daily_ledger

  def self.sum_of_closing_balance_of_ledger_dailies_for_ledgers(ledger_ids, date_to_ad)
    closing_balance_sum = 0.0
    Ledger.where(id:ledger_ids).each do |ledger|
      last_day_ledger_daily = ledger.ledger_dailies.by_branch_fy_code.where('date <= ?',date_to_ad).order('date DESC, updated_at DESC').first
      if last_day_ledger_daily.present?
        closing_balance_sum += last_day_ledger_daily.closing_balance
      end
    end
    closing_balance_sum
  end

  private
  def process_daily_ledger
    self.date_bs ||= ad_to_bs_string(self.date)
  end
end
