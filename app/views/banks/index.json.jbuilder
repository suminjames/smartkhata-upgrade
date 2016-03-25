json.array!(@banks) do |bank|
  json.extract! bank, :id, :name, :bank_code, :address, :contact_no
  json.url bank_url(bank, format: :json)
end
