FactoryGirl.define do
  factory :ledger_daily do
    current_user_id { User.first&.id || create(:user).id }
  end
end
