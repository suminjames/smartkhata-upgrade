json.array!(@transaction_messages) do |transaction_message|
  json.extract! transaction_message, :id, :sms_message, :transaction_date, :sms_status, :email_status, :bill_id, :client_account_id
  json.url transaction_message_url(transaction_message, format: :json)
end
