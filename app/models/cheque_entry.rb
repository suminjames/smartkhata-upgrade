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
end
