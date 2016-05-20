class VendorAccount < ActiveRecord::Base
  include ::Models::UpdaterWithBranch

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  has_many :ledgers
  has_many :cheque_entries
end
