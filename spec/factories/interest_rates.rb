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
    start_date "2020-07-31"
    end_date "2020-07-31"
    interest_type 1
    rate 1
  end
end
