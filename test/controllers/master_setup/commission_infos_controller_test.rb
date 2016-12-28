require 'test_helper'

class MasterSetup::CommissionInfosControllerTest < ActionController::TestCase
  setup do
    @master_setup_commission_info = master_setup_commission_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:master_setup_commission_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create master_setup_commission_info" do
    assert_difference('MasterSetup::CommissionInfo.count') do
      post :create, master_setup_commission_info: { end_date: @master_setup_commission_info.end_date, end_date_bs: @master_setup_commission_info.end_date_bs, start_date: @master_setup_commission_info.start_date, start_date_bs: @master_setup_commission_info.start_date_bs }
    end

    assert_redirected_to master_setup_commission_info_path(assigns(:master_setup_commission_info))
  end

  test "should show master_setup_commission_info" do
    get :show, id: @master_setup_commission_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @master_setup_commission_info
    assert_response :success
  end

  test "should update master_setup_commission_info" do
    patch :update, id: @master_setup_commission_info, master_setup_commission_info: { end_date: @master_setup_commission_info.end_date, end_date_bs: @master_setup_commission_info.end_date_bs, start_date: @master_setup_commission_info.start_date, start_date_bs: @master_setup_commission_info.start_date_bs }
    assert_redirected_to master_setup_commission_info_path(assigns(:master_setup_commission_info))
  end

  test "should destroy master_setup_commission_info" do
    assert_difference('MasterSetup::CommissionInfo.count', -1) do
      delete :destroy, id: @master_setup_commission_info
    end

    assert_redirected_to master_setup_commission_infos_path
  end
end
