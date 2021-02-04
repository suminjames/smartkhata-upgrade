class EsewaPayment < ActiveRecord::Base
  belongs_to :payment_transaction
  has_many :esewa_transaction_verifications
end
