# == Schema Information
#
# Table name: esewa_payments
#
#  id              :integer          not null, primary key
#  service_charge  :decimal(, )
#  delivery_charge :decimal(, )
#  tax_amount      :decimal(, )
#  success_url     :string
#  failure_url     :string
#  response_ref    :string
#  response_amount :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null

class EsewaPayment < ActiveRecord::Base
  has_one :payment_transaction, as: :payable

  ########################################
  # Constants
  PAYMENT_URL = Rails.env.production? ? "https://esewa.com.np/epay/main" : "https://uat.esewa.com.np/epay/main"
  PAYMENT_VERIFICATION_URL = Rails.env.production? ? "https://esewa.com.np/epay/transrec" : "https://uat.esewa.com.np/epay/transrec"

  ########################################
  # Includes

  ########################################
  # Relationships

  ########################################
  # Callbacks

  ########################################
  # Validations

  ########################################
  # Enums

  ########################################
  # Scopes

  ########################################
  # Attributes

  ########################################
  # Delegations

  ########################################
  # Methods
  def set_response_ref(ref)
    self.update(response_ref: ref)
  end

  def set_response_amount(amt)
    self.update(response_amount: amt)
  end
end
