# == Schema Information
#
# Table name: payment_transactions
#
#  id               :integer          not null, primary key
#  amount           :string
#  status           :integer
#  response_code    :string
#  response_message :string
#  start_time       :string
#  end_time         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PaymentTransaction < ActiveRecord::Base
  has_many :bills
  has_many :esewa_payments

  enum status: [:success, :fail]
  enum kind: [:esewa, :connectips]
end
