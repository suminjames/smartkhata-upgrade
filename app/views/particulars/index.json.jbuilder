json.array!(@particulars) do |particular|
  json.extract! particular, :id
  json.url particular_url(particular, format: :json)
end
