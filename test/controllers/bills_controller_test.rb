require 'test_helper'
require "#{Rails.root}/app/globalhelpers/custom_date_module"

class BillsControllerTest < ActionController::TestCase
  include CustomDateModule
  setup do
    # Fix FY-Code issue
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
    @assert_block_via_invalid_post = proc { | param_to_skip, error_msg, provided_params |
      share_transaction = ShareTransaction.selling.first
      bs_date = ad_to_bs(share_transaction.date.to_s)
      client_account = share_transaction.client_account
      if provided_params
        bs_date = provided_params[:date_bs] || bs_date
      end
      bill_params = {}
      bill_params[:provisional_base_price] = '100000' unless param_to_skip == :provisional_base_price
      bill_params[:date_bs] = bs_date unless param_to_skip == :date_bs
      bill_params[:client_account_id] = client_account unless param_to_skip == :client_account_id
      assert_no_difference 'Bill.count' do
        post :create, bill: bill_params
      end
      assert_response :success
      # No error flash in simple_form!
      assert_match 'Please review the problems below:', response.body
      assert_match error_msg, response.body
    }
  end

  test "should get index" do
    get :index
    assert_redirected_to bills_path(search_by: "client_name")

    get :index, search_by: 'client_name'
    assert_response :success
    assert_template 'bills/index'
  end

  test "should get new" do
    @assert_via_get.call(:new)
  end

  test "should show bill of both types" do
    @assert_via_get.call(:show, @bill)
    assert_match 'we have Purchased these undernoted stocks', response.body

    @assert_via_get.call(:show, @sales_bill)
    assert_match 'we have Sold these undernoted stocks', response.body
  end

  test "should show bill by bill number" do
    get :show_by_number, number: "#{@bill.fy_code}-#{@bill.bill_number}"
    assert_redirected_to bill_path(@bill)
    assert_not_nil assigns(:bill)
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

    # Remove phone numbers
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

  test "should create bill once for a date" do
    share_transaction = ShareTransaction.selling.first
    bs_date = ad_to_bs(share_transaction.date.to_s)
    client_account = share_transaction.client_account
    assert_difference 'Bill.count', 1 do
      post :create, bill: { date_bs: bs_date, provisional_base_price: '100000', client_account_id: client_account}
    end
    assert_redirected_to bill_path(assigns(:bill))
    # flash outta nowhere?
    assert_equal 'Bill was successfully created.', flash[:notice]

    # Duplicate attempt
    assert_no_difference 'Bill.count' do
      post :create, bill: { date_bs: bs_date, provisional_base_price: '100000', client_account_id: client_account}
    end
    assert_match 'Sales Bill already Created for this date', response.body
  end

  # Testing invalid input
  test "should not create invalid bill: empty param" do
    empty_param_to_err_msg_hash = {:date_bs                => 'Invalid Transaction Date. Date format is YYYY-MM-DD',
                                   :client_account_id      => 'No Sales Transactions Found',
                                   :provisional_base_price => 'Invalid Base Price'}
    empty_param_to_err_msg_hash.each do |empty_param, error_msg|
      @assert_block_via_invalid_post.call(empty_param, error_msg)
    end
  end

  test "should not create invalid bill: date without a share transaction" do
    @assert_block_via_invalid_post.call(nil, 'No Sales Transactions Found', date_bs: '2070-01-10')
  end

  # features not implemented
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
