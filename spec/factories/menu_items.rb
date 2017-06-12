FactoryGirl.define do
  factory :menu_item do
  	sequence(:code) { |n| "Menu-#{n}" }
  end
end