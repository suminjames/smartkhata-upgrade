class ShareInventory < ActiveRecord::Base
  belongs_to :client_account
  belongs_to :isin_info

  # def get_value_by_isin(isin_info)
  #   ShareInventory.where(isin_info_id: isin_info.id).sum(:floorsheet_blnc)
  # end

  # def get_value_by_client(client_account)
  # end


end
