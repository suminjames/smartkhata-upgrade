# == Schema Information
#
# Table name: interest_rates
#
#  id            :integer          not null, primary key
#  start_date    :date
#  end_date      :date
#  interest_type :integer
#  rate          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :interest_rate do
    start_date { Date.today - 30.days }
    end_date { Date.today - 2.days }
    interest_type 0
    rate 10
  end
end
