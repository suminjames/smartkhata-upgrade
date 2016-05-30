json.array!(@nepse_chalans) do |nepse_chalan|
  json.extract! nepse_chalan, :id, :deposited_date_bs, :deposited_date, :voucher_id
  json.url nepse_chalan_url(nepse_chalan, format: :json)
end
