json.array!(@order_requests) do |order_request|
  json.extract! order_request, :id, :date_bs
  json.url order_request_url(order_request, format: :json)
end
