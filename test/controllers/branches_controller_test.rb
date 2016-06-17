require 'test_helper'

class BranchesControllerTest < ActionController::TestCase
  setup do
    @branch = branches(:one)
    sign_in users(:user)

    @assert_block_via_get = Proc.new {|action, instance_var|
      if [:show, :edit].include? action
        get action, id: @branch
      else
        get action
      end
      assert_response :success
      assert_template "branches/#{action}"
      assert_not_nil assigns(instance_var) if instance_var
    }
  end

  test "should get index" do
    @assert_block_via_get.call(:index, :branches)
  end

  test "should get new" do
    @assert_block_via_get.call(:new, :branch)
  end

  test "should create branch" do
    assert_difference 'Branch.count', 1 do
      post :create, branch: { address: @branch.address, code: @branch.code }
    end

    assert_redirected_to branch_path(assigns(:branch))
  end

  test "should show branch" do
    @assert_block_via_get.call(:show)
  end

  test "should get edit" do
    @assert_block_via_get.call(:edit)
  end

  test "should update branch" do
    patch :update, id: @branch, branch: { address: @branch.address, code: @branch.code }
    assert_redirected_to branch_path(assigns(:branch))
  end

  test "should destroy branch" do
    assert_difference('Branch.count', -1) do
      delete :destroy, id: @branch
    end
    assert_redirected_to branches_path
  end
end
