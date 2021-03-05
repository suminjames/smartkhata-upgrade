# == Schema Information
#
# Table name: vouchers
#
#  id                     :integer          not null, primary key
#  fy_code                :integer
#  voucher_number         :integer
#  date                   :date
#  date_bs                :string
#  desc                   :string
#  beneficiary_name       :string
#  voucher_type           :integer          default(0)
#  voucher_status         :integer          default(0)
#  creator_id             :integer
#  updater_id             :integer
#  reviewer_id            :integer
#  branch_id              :integer
#  is_payment_bank        :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_date             :date
#  receipt_transaction_id :integer
#

FactoryGirl.define do
  factory :voucher do
    fy_code 7374
    date_bs '2073-09-24'
    voucher_type 0
    voucher_status 1
    branch_id { Branch.first&.id || create(:branch).id }
    desc nil
    creator { User.first || create(:user) }
    updater { User.first || create(:user) }
    current_tenant { Tenant.first || create(:tenant) }
  end
end
