require 'test_helper'

class NepseSettlementsControllerTest < ActionController::TestCase
  setup do
    @nepse_settlement = nepse_settlements(:one)
    @processed_nepse_settlement = nepse_settlements(:two)
    sign_in users(:user)
  end

  # index
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nepse_settlements)
  end

  # new
  test "allowed user should get new" do
    get :new
    assert_response :success
  end

  # create
  test "should be able to create nepse_settlement" do
    assert_difference('SalesSettlement.count', 1) do
      post :create, nepse_settlement: {  }
    end
    assert_redirected_to nepse_settlement_path(assigns(:nepse_settlement))
  end

  # show
  test "should see nepse_settlement" do
    get :show, id: @nepse_settlement
    assert_response :success
  end

  # edit
  test "should get the nepse_settlement edit path" do
    get :edit, id: @nepse_settlement
    assert_response :success
  end

  # update
  test "should update nepse_settlement" do
    patch :update, id: @nepse_settlement, nepse_settlement: {  }
    assert_redirected_to nepse_settlement_path(assigns(:nepse_settlement))
    # Cannot check some field explicitly, as only the 'status' field exists, which is private
  end

  # destroy
  test "should destroy nepse_settlement" do
    assert_difference('SalesSettlement.count', -1) do
      delete :destroy, id: @nepse_settlement
    end
    assert_redirected_to nepse_settlements_path
  end

  # test process settlement
  test "should process settlement" do
    assert @nepse_settlement.pending?
    get :generate_bills, id: @nepse_settlement
    assert_response :success
    @nepse_settlement.reload
    assert @nepse_settlement.complete?
  end

  test "should throw relevant error when re-processing settlement" do
    assert_not @processed_nepse_settlement.pending?
    get :generate_bills, id: @processed_nepse_settlement
    assert_response :success
    assert_equal 'It has already been processed', flash['error']
  end
end
