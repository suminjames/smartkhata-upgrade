require 'test_helper'

class BranchesControllerTest < ActionController::TestCase
  setup do
    @branch = branches(:one)
    sign_in users(:user)

    @assert_block_via_get = Proc.new {|action, instance_var|
      params = [:show, :edit].include?(action) ? {id: @branch} : {}
      get action, params
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
      post :create, branch: { address: 'Utopia', code: 'BR' }
      # debugger
    end
    assert_redirected_to branch_path(assigns(:branch))
  end

  # Briefly testing invalid input: duplicate branch code
  test "should not create invalid branch- duplicate code" do
    assert_no_difference 'Branch.count'do
      post :create, branch: { address: 'Utopia', code: @branch.code }
    end
    assert_response :success
    assert_match 'has already been taken', response.body
    # simple_form does not use flash?
    # assert_not_nil flash[:error]
  end

  test "should show branch" do
    @assert_block_via_get.call(:show)
  end

  test "should get edit" do
    @assert_block_via_get.call(:edit)
  end

  test "should update branch" do
    assert_not_equal 'SJ', @branch.code
    patch :update, id: @branch, branch: { address: 'San Jose', code: 'SJ' }
    assert_redirected_to branch_path(assigns(:branch))

    @branch.reload
    assert_equal 'SJ', @branch.code
  end

  test "should destroy branch" do
    assert_difference('Branch.count', -1) do
      delete :destroy, id: @branch
    end
    assert_redirected_to branches_path
  end
end
