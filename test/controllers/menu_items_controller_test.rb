=begin
require 'test_helper'

class MenuItemsControllerTest < ActionController::TestCase
  setup do
    @menu_item = menu_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:menu_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create menu_item" do
    assert_difference('MenuItem.count') do
      post :create, menu_item: { code: @menu_item.code, hide_on_main_navigation: @menu_item.hide_on_main_navigation, name: @menu_item.name, path: @menu_item.path, references: @menu_item.references }
    end

    assert_redirected_to menu_item_path(assigns(:menu_item))
  end

  test "should show menu_item" do
    get :show, id: @menu_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @menu_item
    assert_response :success
  end

  test "should update menu_item" do
    patch :update, id: @menu_item, menu_item: { code: @menu_item.code, hide_on_main_navigation: @menu_item.hide_on_main_navigation, name: @menu_item.name, path: @menu_item.path, references: @menu_item.references }
    assert_redirected_to menu_item_path(assigns(:menu_item))
  end

  test "should destroy menu_item" do
    assert_difference('MenuItem.count', -1) do
      delete :destroy, id: @menu_item
    end

    assert_redirected_to menu_items_path
  end
end
=end