require 'test_helper'

class MasterSetup::CommissionRatesControllerTest < ActionController::TestCase
  setup do
    @master_setup_commission_rate = master_setup_commission_rates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:master_setup_commission_rates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create master_setup_commission_rate" do
    assert_difference('MasterSetup::CommissionRate.count') do
      post :create, master_setup_commission_rate: { amount_gt: @master_setup_commission_rate.amount_gt, amount_lt_eq: @master_setup_commission_rate.amount_lt_eq, date_from: @master_setup_commission_rate.date_from, date_to: @master_setup_commission_rate.date_to, is_flat_rate: @master_setup_commission_rate.is_flat_rate, rate: @master_setup_commission_rate.rate, remarks: @master_setup_commission_rate.remarks }
    end

    assert_redirected_to master_setup_commission_rate_path(assigns(:master_setup_commission_rate))
  end

  test "should show master_setup_commission_rate" do
    get :show, id: @master_setup_commission_rate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @master_setup_commission_rate
    assert_response :success
  end

  test "should update master_setup_commission_rate" do
    patch :update, id: @master_setup_commission_rate, master_setup_commission_rate: { amount_gt: @master_setup_commission_rate.amount_gt, amount_lt_eq: @master_setup_commission_rate.amount_lt_eq, date_from: @master_setup_commission_rate.date_from, date_to: @master_setup_commission_rate.date_to, is_flat_rate: @master_setup_commission_rate.is_flat_rate, rate: @master_setup_commission_rate.rate, remarks: @master_setup_commission_rate.remarks }
    assert_redirected_to master_setup_commission_rate_path(assigns(:master_setup_commission_rate))
  end

  test "should destroy master_setup_commission_rate" do
    assert_difference('MasterSetup::CommissionRate.count', -1) do
      delete :destroy, id: @master_setup_commission_rate
    end

    assert_redirected_to master_setup_commission_rates_path
  end
end
