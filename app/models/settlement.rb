class Settlement < ActiveRecord::Base
  belongs_to :voucher
  include ::Models::Updater
  enum settlement_type: [ :receipt, :payment]
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
end
