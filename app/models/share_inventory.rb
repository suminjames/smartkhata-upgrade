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
