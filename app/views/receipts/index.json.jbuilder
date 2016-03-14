json.array!(@receipts) do |receipt|
  json.extract! receipt, :id, :name, :amount, :amount, :date_bs, :description, :cheque_entry_id
  json.url receipt_url(receipt, format: :json)
end