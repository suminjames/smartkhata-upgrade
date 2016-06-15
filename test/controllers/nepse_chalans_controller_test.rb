=begin
require 'test_helper'

class NepseChalansControllerTest < ActionController::TestCase
  setup do
    @nepse_chalan = nepse_chalans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nepse_chalans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nepse_chalan" do
    assert_difference('NepseChalan.count') do
      post :create, nepse_chalan: { deposited_date: @nepse_chalan.deposited_date, deposited_date_bs: @nepse_chalan.deposited_date_bs, voucher_id: @nepse_chalan.voucher_id }
    end

    assert_redirected_to nepse_chalan_path(assigns(:nepse_chalan))
  end

  test "should show nepse_chalan" do
    get :show, id: @nepse_chalan
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nepse_chalan
    assert_response :success
  end

  test "should update nepse_chalan" do
    patch :update, id: @nepse_chalan, nepse_chalan: { deposited_date: @nepse_chalan.deposited_date, deposited_date_bs: @nepse_chalan.deposited_date_bs, voucher_id: @nepse_chalan.voucher_id }
    assert_redirected_to nepse_chalan_path(assigns(:nepse_chalan))
  end

  test "should destroy nepse_chalan" do
    assert_difference('NepseChalan.count', -1) do
      delete :destroy, id: @nepse_chalan
    end

    assert_redirected_to nepse_chalans_path
  end
end
=end