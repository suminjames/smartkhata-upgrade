require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:one)
    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    sign_in users(:user)
  end

  test "should get index" do
    get :index
    assert_redirected_to bills_path(search_by: "client_name")
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:bill)
  end

  test "should show bill" do
    get :show, id: @bill
    assert_response :success
    assert_not_nil assigns(:bill)
  end

  # feature not implemented
  test "should not create bill" do
    exception = assert_raises(Exception) { post :create, bill: {  }}
    assert_equal( "NotImplementedError", exception.message )
  end
  test "should not update bill" do
    exception = assert_raises(Exception) { patch :update, id: @bill, bill: {  }}
    assert_equal( "NotImplementedError", exception.message )
  end

  test "should not destroy bill" do
    # assert_difference('Bill.count', -1) do
    #   delete :destroy, id: @bill
    # end
    exception = assert_raises(Exception) { delete :destroy, id: @bill}
    assert_equal( "NotImplementedError", exception.message )
  end
  # test "should get edit" do
  #   get :edit, id: @bill
  #   assert_response :success
  # end
end
