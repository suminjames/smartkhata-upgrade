# == Schema Information
#
# Table name: ledger_dailies
#
#  id           :integer          not null, primary key
#  date         :date
#  dr_amount    :decimal(15, 4)   default("0.0")
#  cr_amount    :decimal(15, 4)   default("0.0")
#  opening_blnc :decimal(15, 4)   default("0.0")
#  closing_blnc :decimal(15, 4)   default("0.0")
#  date_bs      :string
#  ledger_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

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
