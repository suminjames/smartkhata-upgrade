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
  has_one :payment_transaction, as: :payable
end
