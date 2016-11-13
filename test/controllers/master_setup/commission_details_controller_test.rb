require 'test_helper'

class MasterSetup::CommissionDetailsControllerTest < ActionController::TestCase
  setup do
    @master_setup_commission_detail = master_setup_commission_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:master_setup_commission_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create master_setup_commission_detail" do
    assert_difference('MasterSetup::CommissionDetail.count') do
      post :create, master_setup_commission_detail: { commission_amount: @master_setup_commission_detail.commission_amount, commission_rate: @master_setup_commission_detail.commission_rate, limit_amount: @master_setup_commission_detail.limit_amount, master_setup_commission_info_id: @master_setup_commission_detail.master_setup_commission_info_id, start_amount: @master_setup_commission_detail.start_amount }
    end

    assert_redirected_to master_setup_commission_detail_path(assigns(:master_setup_commission_detail))
  end

  test "should show master_setup_commission_detail" do
    get :show, id: @master_setup_commission_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @master_setup_commission_detail
    assert_response :success
  end

  test "should update master_setup_commission_detail" do
    patch :update, id: @master_setup_commission_detail, master_setup_commission_detail: { commission_amount: @master_setup_commission_detail.commission_amount, commission_rate: @master_setup_commission_detail.commission_rate, limit_amount: @master_setup_commission_detail.limit_amount, master_setup_commission_info_id: @master_setup_commission_detail.master_setup_commission_info_id, start_amount: @master_setup_commission_detail.start_amount }
    assert_redirected_to master_setup_commission_detail_path(assigns(:master_setup_commission_detail))
  end

  test "should destroy master_setup_commission_detail" do
    assert_difference('MasterSetup::CommissionDetail.count', -1) do
      delete :destroy, id: @master_setup_commission_detail
    end

    assert_redirected_to master_setup_commission_details_path
  end
end
