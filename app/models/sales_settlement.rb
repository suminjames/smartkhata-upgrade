class SalesSettlement < ActiveRecord::Base
  enum status: [:pending, :complete]
  include ::Models::Updater

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
end
