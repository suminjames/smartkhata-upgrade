json.array!(@user_access_roles) do |user_access_role|
  json.extract! user_access_role, :id, :role_type, :role_name
  json.url user_access_role_url(user_access_role, format: :json)
end
