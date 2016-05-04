json.array!(@branches) do |branch|
  json.extract! branch, :id, :code, :address
  json.url branch_url(branch, format: :json)
end
