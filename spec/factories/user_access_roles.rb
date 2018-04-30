FactoryBot.define do
  factory :user_access_role do
  	role_type 1
  	sequence(:role_name) { |n| "Role-#{n}" }
  end
end
