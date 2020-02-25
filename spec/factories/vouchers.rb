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
