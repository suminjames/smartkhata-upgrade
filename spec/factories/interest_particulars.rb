# == Schema Information
#
# Table name: interest_particulars
#
#  id            :integer          not null, primary key
#  amount        :string
#  rate          :integer
#  date          :date
#  interest_type :integer
#  ledger_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :interest_particular do
    amount { 1000 }
    rate { 10 }
    date { Date.today }
    interest_type { 'dr' }
    ledger_id { 1 }
  end
end
