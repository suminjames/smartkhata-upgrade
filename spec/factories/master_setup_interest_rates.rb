FactoryGirl.define do
  factory :master_setup_interest_rate, class: 'MasterSetup::InterestRate' do
    start_date "2020-07-30"
    end_date "2020-07-30"
    interest_type "MyString"
    rate 1
  end
end
