json.array!(@employee_accounts) do |employee_account|
  json.extract! employee_account, :id
  json.url employee_account_url(employee_account, format: :json)
end
