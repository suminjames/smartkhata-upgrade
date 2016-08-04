require 'test_helper'

class SalesSettlementsControllerTest < ActionController::TestCase
  setup do
    @sales_settlement = sales_settlements(:one)
    @processed_sales_settlement = sales_settlements(:two)
    sign_in users(:user)
  end

  # index
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_settlements)
  end

  # new
  test "allowed user should get new" do
    get :new
    assert_response :success
  end

  # create
  test "should be able to create sales_settlement" do
    assert_difference('SalesSettlement.count', 1) do
      post :create, sales_settlement: {  }
    end
    assert_redirected_to sales_settlement_path(assigns(:sales_settlement))
  end

  # show
  test "should see sales_settlement" do
    get :show, id: @sales_settlement
    assert_response :success
  end

  # edit
  test "should get the sales_settlement edit path" do
    get :edit, id: @sales_settlement
    assert_response :success
  end

  # update
  test "should update sales_settlement" do
    patch :update, id: @sales_settlement, sales_settlement: {  }
    assert_redirected_to sales_settlement_path(assigns(:sales_settlement))
    # Cannot check some field explicitly, as only the 'status' field exists, which is private
  end

  # destroy
  test "should destroy sales_settlement" do
    assert_difference('SalesSettlement.count', -1) do
      delete :destroy, id: @sales_settlement
    end
    assert_redirected_to sales_settlements_path
  end

  # test process settlement
  test "should process settlement" do
    assert @sales_settlement.pending?
    get :generate_bills, id: @sales_settlement
    assert_response :success
    @sales_settlement.reload
    assert @sales_settlement.complete?
  end

  test "should throw relevant error when re-processing settlement" do
    assert_not @processed_sales_settlement.pending?
    get :generate_bills, id: @processed_sales_settlement
    assert_response :success
    assert_equal 'It has already been processed', flash['error']
  end
end
