# == Schema Information
#
# Table name: public.tenants
#
#  id           :integer          not null, primary key
#  name         :string
#  dp_id        :string
#  full_name    :string
#  phone_number :string
#  address      :string
#  pan_number   :string
#  fax_number   :string
#  broker_code  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class TenantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
