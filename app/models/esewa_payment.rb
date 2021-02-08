class EsewaPayment < ActiveRecord::Base
  PAYMENT_URL = Rails.env.production? ? "https://esewa.com.np/epay/main" : "https://uat.esewa.com.np/epay/main"

  has_many :esewa_transaction_verifications
  has_many :bills
end