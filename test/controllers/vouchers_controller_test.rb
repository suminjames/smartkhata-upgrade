require 'test_helper'

class VouchersControllerTest < ActionController::TestCase
  setup do
    @voucher = vouchers(:one)
  end

# Disabled. Voucher is 'get' within ledger and not independently.
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:vouchers)
  # end

# TODO
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

# TODO
  # test "should create voucher" do
  #   assert_difference('Voucher.count') do
  #     post :create, voucher: {  }
  #   end
  #
  #   assert_redirected_to voucher_path(assigns(:voucher))
  # end

  # test "should show voucher" do
  #   get :show, id: @voucher
  #   assert_response :success
  # end

# TODO
  # test "should get edit" do
  #   get :edit, id: @voucher
  #   assert_response :success
  # end

# Updating voucher should not be allowed.
  # test "should update voucher" do
  #   patch :update, id: @voucher, voucher: {  }
  #   assert_redirected_to voucher_path(assigns(:voucher))
  # end

  # test "should destroy voucher" do
  #   assert_difference('Voucher.count', -1) do
  #     delete :destroy, id: @voucher
  #   end
  #
  #   assert_redirected_to vouchers_path
  # end
end
