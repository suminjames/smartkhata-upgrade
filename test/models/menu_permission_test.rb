# == Schema Information
#
# Table name: menu_permissions
#
#  id           :integer          not null, primary key
#  creator_id   :integer
#  updater_id   :integer
#  menu_item_id :integer
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class MenuPermissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
