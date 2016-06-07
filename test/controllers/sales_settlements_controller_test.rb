require 'test_helper'

class SalesSettlementsControllerTest < ActionController::TestCase
  setup do
    @sales_settlement = sales_settlements(:one)
  end

  # index
  test "unauthenticated users should not get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  test "allowed users should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_settlements)
  end

  # new
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end

  test "allowed user should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
  end

  # create
  test "allowed users should be able to create sales_settlement" do
    sign_in users(:user)
    assert_difference('SalesSettlement.count', 1) do
      post :create, sales_settlement: {  }
    end
    assert_redirected_to sales_settlement_path(assigns(:sales_settlement))
  end

  test "unauthenticated users should not be able to create sales_settlement" do
    assert_no_difference('SalesSettlement.count') do
      post :create, sales_settlement: {  }
    end
    assert_redirected_to new_user_session_path
  end

  # show
  test "unauthenticated users should not see sales_settlement" do
    get :show, id: @sales_settlement
    assert_redirected_to new_user_session_path
  end
  
  test "allowed users should see sales_settlement" do
    sign_in users(:user)
    get :show, id: @sales_settlement
    assert_response :success
  end

  # edit
  test "unauthenticated users should not get the sales_settlement edit path" do
    get :edit, id: @sales_settlement
    assert_redirected_to new_user_session_path
  end
  
  test "allowed users should get the sales_settlement edit path" do
    sign_in users(:user)
    get :edit, id: @sales_settlement
    assert_response :success
  end

  # update
  test "unauthenticated users should not be able to update sales_settlement" do
    patch :update, id: @sales_settlement, sales_settlement: {  }
    assert_redirected_to new_user_session_path
    # Check the unchanged value?
  end
  
  test "allowed users should be able to update sales_settlement" do
    sign_in users(:user)
    patch :update, id: @sales_settlement, sales_settlement: {  }
    assert_redirected_to sales_settlement_path(assigns(:sales_settlement))
    # Check the updated value?
  end

  # destroy
  test "unauthenticated users should not be able to destroy sales_settlement" do
    assert_no_difference('SalesSettlement.count') do
      delete :destroy, id: @sales_settlement
      assert_redirected_to new_user_session_path
    end
  end
  
  test "allowed users should be able to destroy sales_settlement" do
    sign_in users(:user)
    assert_difference('SalesSettlement.count', -1) do
      delete :destroy, id: @sales_settlement
    end
    assert_redirected_to sales_settlements_path
  end

end
