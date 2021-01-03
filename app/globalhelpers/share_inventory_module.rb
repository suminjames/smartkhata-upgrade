module ShareInventoryModule
  def update_share_inventory(client_id, isin_info_id, quantity, current_user_id, is_incremented, is_deal_cancelled = false)
    share_inventory = ShareInventory.find_or_initialize_by(
        client_account_id: client_id,
        isin_info_id: isin_info_id
    )
    share_inventory.lock!

    if is_deal_cancelled
      if is_incremented
        share_inventory.total_in -= quantity
        share_inventory.floorsheet_blnc -= quantity
      else
        share_inventory.total_out -= quantity
        share_inventory.floorsheet_blnc += quantity
      end
    elsif is_incremented
      share_inventory.total_in += quantity
      share_inventory.floorsheet_blnc += quantity
    else
      share_inventory.total_out += quantity
      share_inventory.floorsheet_blnc -= quantity
    end
    share_inventory.current_user_id = current_user_id
    share_inventory.save!
  end
end
