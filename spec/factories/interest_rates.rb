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

FactoryBot.define do
  factory :interest_rate do
    start_date { Date.today - 40.days }
    end_date { Date.today - 10.days }
    interest_type { "payable" }
    rate { 10 }
  end
end
