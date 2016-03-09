require 'test_helper'

class SalesSettlementsControllerTest < ActionController::TestCase
  setup do
    @sales_settlement = sales_settlements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_settlements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sales_settlement" do
    assert_difference('SalesSettlement.count') do
      post :create, sales_settlement: {  }
    end

    assert_redirected_to sales_settlement_path(assigns(:sales_settlement))
  end

  test "should show sales_settlement" do
    get :show, id: @sales_settlement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sales_settlement
    assert_response :success
  end

  test "should update sales_settlement" do
    patch :update, id: @sales_settlement, sales_settlement: {  }
    assert_redirected_to sales_settlement_path(assigns(:sales_settlement))
  end

  test "should destroy sales_settlement" do
    assert_difference('SalesSettlement.count', -1) do
      delete :destroy, id: @sales_settlement
    end

    assert_redirected_to sales_settlements_path
  end
end
