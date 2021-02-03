FactoryBot.define do
  factory :nepse_settlement do
    settlement_id { '12345' }
    settlement_date { "2016-12-01" }
    current_user_id { User.first&.id || create(:user).id }
    creator_id { User.first&.id || create(:user).id }
    updater_id { User.first&.id || create(:user).id }

    factory :nepse_sale_settlement do
      type { 'NepseSaleSettlement' }
    end
  end
end
