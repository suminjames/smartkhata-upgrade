FactoryBot.define do
  factory :edis_item do
    edis_report nil
    contract_number { "" }
    settlement_id { 1 }
    settlement_date { "2020-05-16" }
    scrip { "MyString" }
    boid { "MyString" }
    client_code { "MyString" }
    quantity { 1 }
    wacc { "9.99" }
  end
end
