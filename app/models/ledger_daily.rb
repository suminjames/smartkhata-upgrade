class LedgerDaily < ActiveRecord::Base
  include CustomDateModule
  include ::Models::UpdaterWithBranchFycode

  belongs_to :ledger
  before_save :process_daily_ledger
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
  private
  def process_daily_ledger
    self.date_bs ||= ad_to_bs(self.date)
  end
end
