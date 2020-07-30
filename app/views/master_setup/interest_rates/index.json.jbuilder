json.array!(@master_setup_interest_rates) do |master_setup_interest_rate|
  json.extract! master_setup_interest_rate, :id, :start_date, :end_date, :interest_type, :rate
  json.url master_setup_interest_rate_url(master_setup_interest_rate, format: :json)
end
