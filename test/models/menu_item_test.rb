# == Schema Information
#
# Table name: menu_items
#
#  id                      :integer          not null, primary key
#  name                    :string
#  path                    :string
#  hide_on_main_navigation :boolean          default("false")
#  request_type            :integer          default("0")
#  code                    :string
#  ancestry                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'test_helper'

class MenuItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
