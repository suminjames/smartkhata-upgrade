json.array!(@master_setup_commission_rates) do |master_setup_commission_rate|
  json.extract! master_setup_commission_rate, :id, :date_from, :date_to, :amount_gt, :amount_lt_eq, :rate, :is_flat_rate, :remarks
  json.url master_setup_commission_rate_url(master_setup_commission_rate, format: :json)
end
