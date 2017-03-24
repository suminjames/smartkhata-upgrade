require 'test_helper'

class UserAccessRolesControllerTest < ActionController::TestCase
  setup do
    @request.host = 'trishakti.lvh.me'
    set_branch_id 1
    sign_in users(:user)
    @user_access_role = user_access_roles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_access_roles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_access_role" do
    assert_difference('UserAccessRole.count') do
      post :create, user_access_role: { role_name: @user_access_role.role_name.reverse, role_type: @user_access_role.role_type }
    end

    assert_redirected_to user_access_role_path(assigns(:user_access_role))
  end

  test "should show user_access_role" do
    get :show, id: @user_access_role
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_access_role
    assert_response :success
  end

  test "should update user_access_role" do
    patch :update, id: @user_access_role, user_access_role: { role_name: @user_access_role.role_name, role_type: @user_access_role.role_type }
    assert_redirected_to user_access_role_path(assigns(:user_access_role))
  end

  test "should destroy user_access_role" do
    assert_difference('UserAccessRole.count', -1) do
      delete :destroy, id: @user_access_role
    end

    assert_redirected_to user_access_roles_path
  end
end
