class NepseChalan < ActiveRecord::Base
  # added the updater and creater user tracking
  include ::Models::UpdaterWithBranchFycode

  belongs_to :voucher
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  has_many :share_transactions

end
