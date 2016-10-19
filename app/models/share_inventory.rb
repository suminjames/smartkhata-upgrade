# == Schema Information
#
# Table name: share_inventories
#
#  id                :integer          not null, primary key
#  isin_desc         :string
#  current_blnc      :decimal(10, 3)   default(0.0)
#  free_blnc         :decimal(10, 3)   default(0.0)
#  freeze_blnc       :decimal(10, 3)   default(0.0)
#  dmt_pending_veri  :decimal(10, 3)   default(0.0)
#  dmt_pending_conf  :decimal(10, 3)   default(0.0)
#  rmt_pending_conf  :decimal(10, 3)   default(0.0)
#  safe_keep_blnc    :decimal(10, 3)   default(0.0)
#  lock_blnc         :decimal(10, 3)   default(0.0)
#  earmark_blnc      :decimal(10, 3)   default(0.0)
#  elimination_blnc  :decimal(10, 3)   default(0.0)
#  avl_lend_blnc     :decimal(10, 3)   default(0.0)
#  lend_blnc         :decimal(10, 3)   default(0.0)
#  borrow_blnc       :decimal(10, 3)   default(0.0)
#  pledge_blnc       :decimal(10, 3)   default(0.0)
#  total_in          :decimal(10, )    default(0)
#  total_out         :decimal(10, )    default(0)
#  floorsheet_blnc   :decimal(10, )    default(0)
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
  include Auditable
  include ::Models::UpdaterWithBranch

  belongs_to :client_account
  belongs_to :isin_info

  scope :by_client_id, -> (id) { where(client_account_id: id) }

  # def get_value_by_isin(isin_info)
  #   ShareInventory.where(isin_info_id: isin_info.id).sum(:floorsheet_blnc)
  # end

  # def get_value_by_client(client_account)
  # end

  def self.with_most_quantity
    query = ShareInventory.joins(:isin_info).select('isin_infos.isin as isin, sum(share_inventories.floorsheet_blnc) as total').group('isin_infos.id').order("total DESC").limit(1)
    query.first
  end

  def self.group_by_isin_for_client(client_id)
    ShareInventory.joins(:isin_info).by_client_id(client_id).select('isin_infos.isin as isin, sum(share_inventories.floorsheet_blnc) as total').group('isin_infos.id').order("total DESC")
  end

end
