require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:one)
  end

  test "should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:bills)
  end

  test "should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
  end

  # feature not implemented
  test "should not create bill" do
    sign_in users(:user)
    post :create, bill: {  }
    assert NotImplementedError
  end


  test "should show bill" do
    sign_in users(:user)
    get :show, id: @bill
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:user)
    get :edit, id: @bill
    assert_response :success
  end



  # feature not implemented
  test "should not update bill" do
    sign_in users(:user)
    patch :update, id: @bill, bill: {  }
    assert NotImplementedError

  end

  test "should not destroy bill" do
    sign_in users(:user)
    assert_difference('Bill.count', -1) do
      delete :destroy, id: @bill
    end

    assert_redirected_to bills_path
  end
end
