# == Schema Information
#
# Table name: vendor_accounts
#
#  id           :integer          not null, primary key
#  name         :string
#  address      :string
#  phone_number :string
#  creator_id   :integer
#  updater_id   :integer
#  branch_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class VendorAccount < ActiveRecord::Base
  include ::Models::UpdaterWithBranch

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  has_many :ledgers
  has_many :cheque_entries
end
