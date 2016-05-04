# == Schema Information
#
# Table name: cheque_entries
#
#  id                 :integer          not null, primary key
#  cheque_number      :integer
#  additional_bank_id :integer
#  bank_account_id    :integer
#  particular_id      :integer
#  settlement_id      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ChequeEntry < ActiveRecord::Base
  include ::Models::UpdaterWithBranch

  belongs_to :client_account
  belongs_to :bank_account
  belongs_to :particular
  belongs_to :voucher
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  validates :cheque_number, uniqueness: { scope: :additional_bank_id, message: "should be unique" }
end
