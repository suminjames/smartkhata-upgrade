class ChequeEntry < ActiveRecord::Base
  include ::Models::Updater

  belongs_to :bank_account
  belongs_to :particular
  belongs_to :voucher
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  validates :cheque_number, uniqueness: { scope: :additional_bank_id, message: "should be unique" }
end
