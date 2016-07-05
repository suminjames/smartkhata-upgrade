=begin
require 'test_helper'

class MenuPermissionsControllerTest < ActionController::TestCase
  setup do
    @menu_permission = menu_permissions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:menu_permissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create menu_permission" do
    assert_difference('MenuPermission.count') do
      post :create, menu_permission: { menu_item_id: @menu_permission.menu_item_id, references: @menu_permission.references, user: @menu_permission.user }
    end

    assert_redirected_to menu_permission_path(assigns(:menu_permission))
  end

  test "should show menu_permission" do
    get :show, id: @menu_permission
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @menu_permission
    assert_response :success
  end

  test "should update menu_permission" do
    patch :update, id: @menu_permission, menu_permission: { menu_item_id: @menu_permission.menu_item_id, references: @menu_permission.references, user: @menu_permission.user }
    assert_redirected_to menu_permission_path(assigns(:menu_permission))
  end

  test "should destroy menu_permission" do
    assert_difference('MenuPermission.count', -1) do
      delete :destroy, id: @menu_permission
    end

    assert_redirected_to menu_permissions_path
  end
end
=end