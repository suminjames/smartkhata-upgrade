FactoryBot.define do
  factory :nepse_settlement do
    settlement_id { '12345' }
    settlement_date { "2016-12-01" }

    factory :nepse_sale_settlement do
      type { 'NepseSaleSettlement' }
    end
  end
end
