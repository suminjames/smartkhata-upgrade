json.array!(@cheque_entries) do |cheque_entry|
  json.extract! cheque_entry, :id
  json.url cheque_entry_url(cheque_entry, format: :json)
end
