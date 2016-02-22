json.array!(@share_transactions) do |share_transaction|
  json.extract! share_transaction, :id
  json.url share_transaction_url(share_transaction, format: :json)
end
