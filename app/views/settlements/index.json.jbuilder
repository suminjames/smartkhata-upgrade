json.array!(@settlements) do |settlement|
  json.extract! settlement, :id, :name, :amount, :date_bs, :description, :settlement_type, :voucher_id
  json.url settlement_url(settlement, format: :json)
end
