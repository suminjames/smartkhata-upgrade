# == Schema Information
#
# Table name: nepse_chalans
#
#  id                  :integer          not null, primary key
#  chalan_amount       :decimal(15, 4)   default("0")
#  transaction_type    :integer
#  deposited_date_bs   :string
#  deposited_date      :date
#  nepse_settlement_id :string
#  voucher_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :integer
#  updater_id          :integer
#  fy_code             :integer
#  branch_id           :integer
#

class NepseChalan < ActiveRecord::Base
  # added the updater and creater user tracking
  include ::Models::UpdaterWithBranchFycode

  belongs_to :voucher
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  has_many :share_transactions

end
