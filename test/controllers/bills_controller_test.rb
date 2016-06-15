require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @bill = bills(:one)
    @sales_bill = bills(:two)
    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    @assert_via_get = Proc.new {|action, bill|
      get action, id: bill
      assert_response :success
      assert_not_nil assigns(:bill)
      assert_template "bills/#{action}"
    }
  end

  test "should get index" do
    get :index
    assert_redirected_to bills_path(search_by: "client_name")

    get index, search_by: 'client_name'
    assert_response :success
    assert_template 'bills/index'
  end

  test "should get new" do
    @assert_via_get.call(:new)
  end

  test "should show bill of both types" do
    @assert_via_get.call(:show, @bill)
    assert_match 'we have Purchashed these undernoted stocks', response.body # note the typo

    @assert_via_get.call(:show, @sales_bill)
    assert_match 'we have Sold these undernoted stocks', response.body
  end

  test "should show bill by bill number" do
    get :show_by_number, number: "#{@bill.fy_code}-#{@bill.bill_number}"
    assert_redirected_to bill_path(@bill)
    assert_not_nil assigns(:bill)
    assert_template 'bills/show'
  end

  test "bill should show phone numbers when present" do
    phone = @bill.client_account.phone
    phone_permanent = @bill.client_account.phone_perm
    assert_not_nil phone
    assert_not_nil phone_permanent
    get :show, id: @bill
    # assert_match "#{phone_num", response.body
    [phone, phone_permanent].each do |phone_num|
      assert_select 'div.row.customer_details td', text: "#{phone_num}"
    end

    @bill.client_account.phone = @bill.client_account.phone_perm = nil
    @bill.client_account.save
    @bill.reload
    assert_nil @bill.client_account.phone
    assert_nil @bill.client_account.phone_perm

    get :show, id: @bill
    assert_response :success
    # assert_match 'N/A', response.body
    assert_select 'div.row.customer_details td', text: "N/A", count: 2
  end

  test "should process selected bills" do
    assert_not_equal 'settled', @bill.status
    assert_not_equal 0.0, @bill.balance_to_pay.to_f
    get :show, id: @bill
    assert_select 'img[src^="/assets/settled"]', count: 0 # no settled image
    post :process_selected, bill_ids: [@bill.id], client_account_id: @bill.client_account.id
    assert_response :success
    get :show, id: @bill
    assert_select 'img[src^="/assets/settled"]' # settled image
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
