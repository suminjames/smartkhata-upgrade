require 'test_helper'

class ShareInventoriesControllerTest < ActionController::TestCase
  setup do
    @share_inventory = share_inventories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:share_inventories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create share_inventory" do
    assert_difference('ShareInventory.count') do
      post :create, share_inventory: {  }
    end

    assert_redirected_to share_inventory_path(assigns(:share_inventory))
  end

  test "should show share_inventory" do
    get :show, id: @share_inventory
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @share_inventory
    assert_response :success
  end

  test "should update share_inventory" do
    patch :update, id: @share_inventory, share_inventory: {  }
    assert_redirected_to share_inventory_path(assigns(:share_inventory))
  end

  test "should destroy share_inventory" do
    assert_difference('ShareInventory.count', -1) do
      delete :destroy, id: @share_inventory
    end

    assert_redirected_to share_inventories_path
  end
end
