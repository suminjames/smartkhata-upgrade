# == Schema Information
#
# Table name: master_setup_interest_rates
#
#  id            :integer          not null, primary key
#  start_date    :date
#  end_date      :date
#  interest_type :string
#  rate          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :master_setup_interest_rate, class: 'MasterSetup::InterestRate' do
    start_date "2020-07-30"
    end_date "2020-07-30"
    interest_type "MyString"
    rate 1
  end
end
