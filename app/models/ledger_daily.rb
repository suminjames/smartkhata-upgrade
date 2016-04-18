class LedgerDaily < ActiveRecord::Base
  include CustomDateModule

  belongs_to :ledger
  before_save :process_daily_ledger

  private
  def process_daily_ledger
    self.date_bs ||= ad_to_bs(self.date)
  end
end
