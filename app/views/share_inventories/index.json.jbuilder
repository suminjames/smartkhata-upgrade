json.array!(@share_inventories) do |share_inventory|
  json.extract! share_inventory, :id
  json.url share_inventory_url(share_inventory, format: :json)
end
