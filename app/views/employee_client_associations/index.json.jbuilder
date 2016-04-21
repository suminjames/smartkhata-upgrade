json.array!(@employee_client_associations) do |employee_client_association|
  json.extract! employee_client_association, :id
  json.url employee_client_association_url(employee_client_association, format: :json)
end
