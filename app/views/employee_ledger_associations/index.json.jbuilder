json.array!(@employee_ledger_associations) do |employee_ledger_association|
  json.extract! employee_ledger_association, :id
  json.url employee_ledger_association_url(employee_ledger_association, format: :json)
end
