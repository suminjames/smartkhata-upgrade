# == Schema Information
#
# Table name: user_access_roles
#
#  id          :integer          not null, primary key
#  role_type   :integer          default(0)
#  role_name   :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class UserAccessRoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
