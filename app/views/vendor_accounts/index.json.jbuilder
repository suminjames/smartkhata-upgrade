json.array!(@vendor_accounts) do |vendor_account|
  json.extract! vendor_account, :id, :name, :address, :phone_number
  json.url vendor_account_url(vendor_account, format: :json)
end
