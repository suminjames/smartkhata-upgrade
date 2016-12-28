json.array!(@master_setup_commission_infos) do |master_setup_commission_info|
  json.extract! master_setup_commission_info, :id, :start_date, :end_date, :start_date_bs, :end_date_bs
  json.url master_setup_commission_info_url(master_setup_commission_info, format: :json)
end
