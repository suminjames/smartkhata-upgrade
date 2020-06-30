json.array!(@merge_rebates) do |merge_rebate|
  json.extract! merge_rebate, :id, :scrip, :rebate_start, :rebate_end
  json.url merge_rebate_url(merge_rebate, format: :json)
end
