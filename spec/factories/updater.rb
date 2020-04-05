FactoryBot.define do
  factory :updater, class: User do
    email { 'demo2@gmail.com' }
    password { 'demo123' }
  end
end
