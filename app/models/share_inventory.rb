# == Schema Information
#
# Table name: share_inventories
#
#  id                :integer          not null, primary key
#  isin_desc         :string
#  current_blnc      :decimal(10, 3)   default("0")
#  free_blnc         :decimal(10, 3)   default("0")
#  freeze_blnc       :decimal(10, 3)   default("0")
#  dmt_pending_veri  :decimal(10, 3)   default("0")
#  dmt_pending_conf  :decimal(10, 3)   default("0")
#  rmt_pending_conf  :decimal(10, 3)   default("0")
#  safe_keep_blnc    :decimal(10, 3)   default("0")
#  lock_blnc         :decimal(10, 3)   default("0")
#  earmark_blnc      :decimal(10, 3)   default("0")
#  elimination_blnc  :decimal(10, 3)   default("0")
#  avl_lend_blnc     :decimal(10, 3)   default("0")
#  lend_blnc         :decimal(10, 3)   default("0")
#  borrow_blnc       :decimal(10, 3)   default("0")
#  pledge_blnc       :decimal(10, 3)   default("0")
#  total_in          :decimal(10, )    default("0")
#  total_out         :decimal(10, )    default("0")
#  floorsheet_blnc   :decimal(10, )    default("0")
#  creator_id        :integer
#  updater_id        :integer
#  branch_id         :integer
#  report_date       :date
#  client_account_id :integer
#  isin_info_id      :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#


class ShareInventory < ActiveRecord::Base
  include ::Models::UpdaterWithBranch


  belongs_to :client_account
  belongs_to :isin_info
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  # def get_value_by_isin(isin_info)
  #   ShareInventory.where(isin_info_id: isin_info.id).sum(:floorsheet_blnc)
  # end

  # def get_value_by_client(client_account)
  # end


end
