json.array!(@interest_particulars) do |interest_particular|
  json.extract! interest_particular, :id
  json.url interest_particular_url(interest_particular, format: :json)
end
