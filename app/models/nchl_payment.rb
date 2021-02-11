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

class NchlPayment < ActiveRecord::Base

  ########################################
  # Constants
  PAYMENT_VERIFICATION_URL = Rails.application.secrets.nchl_payment_verification_url
  PAYMENT_URL = Rails.application.secrets.nchl_payment_url

  ########################################
  # Includes

  ########################################
  # Relationships
  has_one :payment_transaction, as: :payable

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
end
