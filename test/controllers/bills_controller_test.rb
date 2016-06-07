require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:one)
    @sales_bill = bills(:two)
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

  test "should show bill by bill number" do
    get :show_by_number, number: "#{@bill.fy_code}-#{@bill.bill_number}"
    assert_redirected_to bill_path(@bill)
    assert_not_nil assigns(:bill)
  end

  test "should process selected bills" do
    assert_not_equal 'settled', @bill.status
    assert_not_equal 0.0, @bill.balance_to_pay.to_f
    post :process_selected, bill_ids: [@bill.id], client_account_id: @bill.client_account.id
    assert_response :success
    @bill.reload
    assert_equal 'settled', @bill.status
    assert_equal 0.0, @bill.balance_to_pay.to_f
  end

  # features not implemented
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
