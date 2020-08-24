json.array!(@edis_reports) do |edis_report|
  json.extract! edis_report, :id, :settlement_id
  # json.url edis_report_url(edis_report, format: :json)
end
