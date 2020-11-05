FactoryBot.define do
  factory :ledger_daily do
    branch
    current_user_id { User.first&.id || create(:user).id }
  end
end
