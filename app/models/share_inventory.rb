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

  def self.with_most_quantity
    query = ShareInventory.joins(:isin_info).select('isin_infos.isin as isin, sum(share_inventories.floorsheet_blnc) as total').group('isin_infos.id').order("total DESC").limit(1)
    query.first
  end

  #
  # Returns a hash with share quantity flows of an isin in a client's inventory.
  # If a client_account_id isn't passed in, returns a hash with share quantity flows of an isin in (not a particular client's inventory but) overall inventory.
  #
  def self.quantity_flow_of_isin_with_client(isin_info_id, client_account_id = nil)
    if client_account_id.present?
      sums = ShareInventory.where(client_account_id: client_account_id, isin_info_id: isin_info_id).first
    else
      sums = ShareInventory.select("SUM(total_in) AS total_in_sum, SUM(total_out) AS total_out_sum, SUM(floorsheet_blnc) AS floorsheet_blnc_sum").where(isin_info_id: isin_info_id)
      sums = sums.to_a.first
    end
    {
        :total_in_sum => sums.total_in,
        :total_out_sum => sums.total_out,
        :floorsheet_blnc_sum => sums.floorsheet_blnc
    }
  end
end
