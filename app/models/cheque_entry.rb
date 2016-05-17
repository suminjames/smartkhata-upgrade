# == Schema Information
#
# Table name: cheque_entries
#
#  id                 :integer          not null, primary key
#  cheque_number      :integer
#  additional_bank_id :integer
#  bank_account_id    :integer
#  particular_id      :integer
#  client_account_id  :integer
#  settlement_id      :integer
#  creator_id         :integer
#  updater_id         :integer
#  branch_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  status             :integer          default("0")
#  cheque_date        :date
#

class ChequeEntry < ActiveRecord::Base
  include ::Models::UpdaterWithBranch

  belongs_to :client_account
  belongs_to :bank_account
  belongs_to :particular
  belongs_to :voucher
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  # validate foreign key: ensures that the bank account exists
  validates :bank_account, presence: true
  validates :cheque_number, presence: true, uniqueness:   { scope: :additional_bank_id, message: "should be unique" },
                                            numericality: { only_integer: true, greater_than: 0 }
  enum status: [:to_be_printed, :printed, :pending_clearance, :void]
end