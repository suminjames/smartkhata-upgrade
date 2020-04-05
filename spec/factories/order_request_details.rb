FactoryBot.define do
  factory :order_request_detail do
    quantity { 1 }
    rate { 1 }
    status { 1 }
    isin_info { nil }
    order_request { nil }
  end
end
