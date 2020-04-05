FactoryBot.define do
  factory :vendor_account do
    name "bhbbi"
    current_user_id { User.first&.id || create(:user).id }
  end
end
