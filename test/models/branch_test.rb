# == Schema Information
#
# Table name: branches
#
#  id         :integer          not null, primary key
#  code       :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  def setup
    @branch = Branch.new(address: 'Utopia', code: 'BR')
    @existing_branch = branches(:one)
  end

  test "should be valid" do
    assert @branch.valid?
  end

  test "Address should not be empty" do
    @branch.address = ' '
    assert @branch.invalid?
  end

  test "Branch code should not be empty" do
    @branch.code = ' '
    assert @branch.invalid?
  end

  test "Branch code should not be duplicate" do
    @branch.code = @existing_branch.code
    assert @branch.invalid?
  end

  test "Branch code should not be duplicate with variable case" do
    @branch.code = @existing_branch.code.capitalize
    assert @branch.invalid?
  end
end
