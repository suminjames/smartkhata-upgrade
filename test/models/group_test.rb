# == Schema Information
#
# Table name: groups
#
#  id                :integer          not null, primary key
#  name              :string
#  parent_id         :integer
#  report            :integer
#  sub_report        :integer
#  for_trial_balance :boolean          default(FALSE)
#  creator_id        :integer
#  updater_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def setup
    @existing_group = groups(:one)
    @group = Group.new(name: 'Some uniq name')
  end

  test "should be valid" do
    assert @group.valid?
  end

  test "name should not be duplicate" do
    @group.name = @existing_group.name
    assert @group.invalid?
  end
end
