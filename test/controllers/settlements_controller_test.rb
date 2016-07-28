require 'test_helper'

class SettlementsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @settlement = settlements(:one)
    # provide current tenant
    @request.host = 'trishakti.lvh.me'

    set_fy_code_and_branch_from @settlement
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settlements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create settlement" do
    assert_difference('Settlement.count') do
      post :create, settlement: { amount: @settlement.amount, date_bs: @settlement.date_bs, description: @settlement.description, name: @settlement.name, settlement_type: @settlement.settlement_type, voucher_id: @settlement.voucher_id }
    end

    assert_redirected_to settlement_path(assigns(:settlement))
  end

  test "should show settlement" do
    get :show, id: @settlement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @settlement
    assert_response :success
  end

  test "should update settlement" do
    patch :update, id: @settlement, settlement: { amount: @settlement.amount, date_bs: @settlement.date_bs, description: @settlement.description, name: @settlement.name, settlement_type: @settlement.settlement_type, voucher_id: @settlement.voucher_id }
    assert_redirected_to settlement_path(assigns(:settlement))
  end

  test "should destroy settlement" do
    assert_difference('Settlement.count', -1) do
      delete :destroy, id: @settlement
    end

    assert_redirected_to settlements_path
  end
end
