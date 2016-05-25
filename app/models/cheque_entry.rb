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
  belongs_to :vendor_account
  belongs_to :bank_account
  belongs_to :additional_bank, class_name: "Bank"
  belongs_to :particular

  # for many to many relation between cheque and the particulars.
  # a cheque can pay/recieve for multiple particulars.
  has_many :payments, -> { payment }, class_name: "ChequeEntryParticularAssociation"
  has_many :receipts, -> { receipt }, class_name: "ChequeEntryParticularAssociation"
  has_many :cheque_entry_particular_associations

  has_many :particulars_on_payment, through: :payments, source: :particular
  has_many :particulars_on_receipt, through: :receipts, source: :particular
  has_many :particulars , through: :cheque_entry_particular_associations


  has_many :vouchers, through: :particulars
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  # TODO (subas) make sure to do the necessary settings
  enum status: [:unassigned, :to_be_printed, :printed, :pending_approval, :pending_clearance, :void, :approved, :bounced, :represented]
  enum cheque_issued_type: [:payment, :receipt]

  validates :cheque_number, uniqueness: { scope: [:additional_bank_id, :bank_account_id ], message: "should be unique" }
  # scope :unassigned, -> { unassigned }

end
