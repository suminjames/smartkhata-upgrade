FactoryBot.define do
  factory :creator, class: User do
    email { 'demo3@gmail.com' }
    password { 'demo123' }
  end
end
