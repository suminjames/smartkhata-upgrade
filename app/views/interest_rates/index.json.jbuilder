json.array!(@interest_rates) do |interest_rate|
  json.extract! interest_rate, :id, :start_date, :end_date, :interest_type, :rate
  json.url interest_rate_url(interest_rate, format: :json)
end
