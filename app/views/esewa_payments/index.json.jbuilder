json.array!(@esewa_payments) do |esewa_payment|
  json.extract! esewa_payment, :id
  json.url esewa_payment_url(esewa_payment, format: :json)
end
