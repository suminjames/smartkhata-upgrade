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

require 'rails_helper'

RSpec.describe NchlPayment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
