# == Schema Information
#
# Table name: nchl_payments
#
#  id           :integer          not null, primary key
#  reference_id :string
#  remarks      :text
#  particular   :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  token        :text
#

FactoryGirl.define do
  factory :nchl_payment do
    reference_id "MyString"
    remarks "MyText"
    particular "MyText"
  end
end
