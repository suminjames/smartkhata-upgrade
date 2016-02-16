json.array!(@vouchers) do |voucher|
  json.extract! voucher, :id
  json.url voucher_url(voucher, format: :json)
end
