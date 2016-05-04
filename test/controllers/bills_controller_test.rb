require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:one)
  end

  test "should get index" do
    sign_in users(:user)
    get :index
    assert_redirected_to  bills_path(search_by: "client_name") 
    # assert_not_nil assigns(:bills)
  end

  test "should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
  end

  # feature not implemented
  test "should not create bill" do
    sign_in users(:user)
    exception = assert_raises(Exception) { post :create, bill: {  }}
    assert_equal( "NotImplementedError", exception.message )
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
    
    exception = assert_raises(Exception) { patch :update, id: @bill, bill: {  }}
    assert_equal( "NotImplementedError", exception.message )

  end

  test "should not destroy bill" do
    sign_in users(:user)
    # assert_difference('Bill.count', -1) do
    #   delete :destroy, id: @bill
    # end

    exception = assert_raises(Exception) { delete :destroy, id: @bill}
    assert_equal( "NotImplementedError", exception.message )

    # assert_redirected_to bills_path
  end
end
