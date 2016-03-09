json.array!(@sales_settlements) do |sales_settlement|
  json.extract! sales_settlement, :id
  json.url sales_settlement_url(sales_settlement, format: :json)
end
