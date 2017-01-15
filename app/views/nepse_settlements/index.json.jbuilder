json.array!(@nepse_settlements) do |nepse_settlement|
  json.extract! nepse_settlement, :id
  json.url nepse_settlement_url(nepse_settlement, format: :json)
end
