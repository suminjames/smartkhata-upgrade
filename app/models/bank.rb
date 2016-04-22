class Bank < ActiveRecord::Base
  include ::Models::Updater
  has_many :bank_accounts
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
  validates :bank_code, uniqueness: true
end
