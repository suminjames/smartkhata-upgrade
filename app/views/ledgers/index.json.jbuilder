json.array!(@ledgers) do |ledger|
  json.extract! ledger, :id
  json.url ledger_url(ledger, format: :json)
end
