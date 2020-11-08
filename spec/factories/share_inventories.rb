FactoryBot.define do
  factory :share_inventory do
    current_user_id { User.first&.id || create(:user).id }
    creator_id { User.first&.id || create(:user).id }
    updater_id { User.first&.id || create(:user).id }
  end
end
