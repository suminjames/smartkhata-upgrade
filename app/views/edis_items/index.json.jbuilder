json.array!(@edis_items) do |edis_item|
  json.extract! edis_item, :id, :edis_report_id, :contract_number, :settlement_id, :settlement_date, :scrip, :boid, :client_code, :quantity, :wacc, :reason_code
  # json.url edis_item_url(edis_item, format: :json)
end
