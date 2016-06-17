json.array!(@sms) do |sm|
  json.extract! sm, :id
  json.url sm_url(sm, format: :json)
end
