class ShareInventoryJob < ActiveJob::Base
  include  ShareInventoryModule

  queue_as :default
  def perform(client_id, isin_info_id, quantity, current_user_id, is_incremented, is_deal_cancelled, current_tenant)
    UserSession.set_console(current_tenant)
    update_share_inventory(client_id, isin_info_id, quantity, current_user_id, is_incremented, is_deal_cancelled)
  end
end
