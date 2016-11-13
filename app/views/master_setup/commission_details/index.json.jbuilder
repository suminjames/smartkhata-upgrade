json.array!(@master_setup_commission_details) do |master_setup_commission_detail|
  json.extract! master_setup_commission_detail, :id, :start_amount, :limit_amount, :commission_rate, :commission_amount, :master_setup_commission_info_id
  json.url master_setup_commission_detail_url(master_setup_commission_detail, format: :json)
end
