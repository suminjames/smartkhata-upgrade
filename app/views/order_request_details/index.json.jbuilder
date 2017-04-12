json.array!(@order_request_details) do |order_request_detail|
  json.extract! order_request_detail, :id, :quantity, :rate, :status, :isin_info_id, :order_request_id
  json.url order_request_detail_url(order_request_detail, format: :json)
end
