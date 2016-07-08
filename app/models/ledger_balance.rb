# == Schema Information
#
# Table name: ledger_balances
#
#  id           :integer          not null, primary key
#  opening_blnc :decimal(15, 4)   default("0.0")
#  closing_blnc :decimal(15, 4)   default("0.0")
#  fy_code      :integer
#  branch_id    :integer
#  creator_id   :integer
#  updater_id   :integer
#  ledger_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class LedgerBalance < ActiveRecord::Base
  belongs_to :ledger
  include ::Models::UpdaterWithFyCode
end
