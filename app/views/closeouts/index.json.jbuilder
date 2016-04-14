json.array!(@closeouts) do |closeout|
  json.extract! closeout, :id
  json.url closeout_url(closeout, format: :json)
end
