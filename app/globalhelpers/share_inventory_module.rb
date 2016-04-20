module ShareInventoryModule
	def update_share_inventory(client_id,isin_info_id, quantity, is_incremented)
		share_inventory = ShareInventory.find_or_create_by(
				client_account_id: client_id,
				isin_info_id: isin_info_id
		)
		share_inventory.lock!

		if is_incremented
			share_inventory.total_in += quantity
			share_inventory.floorsheet_blnc += quantity
		else
			share_inventory.total_out += quantity
			share_inventory.floorsheet_blnc -= quantity
		end

		share_inventory.save!
	end
end
