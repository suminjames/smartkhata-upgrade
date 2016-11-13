json.array!(@isin_infos) do |isin_info|
  json.extract! isin_info, :id, :company, :isin, :sector, :max, :last_price
  json.url isin_info_url(isin_info, format: :json)
end
