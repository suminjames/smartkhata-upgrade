require 'test_helper'

class VendorAccountsControllerTest < ActionController::TestCase
  setup do
    @vendor_account = vendor_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vendor_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vendor_account" do
    assert_difference('VendorAccount.count') do
      post :create, vendor_account: { address: @vendor_account.address, name: @vendor_account.name, phone_number: @vendor_account.phone_number }
    end

    assert_redirected_to vendor_account_path(assigns(:vendor_account))
  end

  test "should show vendor_account" do
    get :show, id: @vendor_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vendor_account
    assert_response :success
  end

  test "should update vendor_account" do
    patch :update, id: @vendor_account, vendor_account: { address: @vendor_account.address, name: @vendor_account.name, phone_number: @vendor_account.phone_number }
    assert_redirected_to vendor_account_path(assigns(:vendor_account))
  end

  test "should destroy vendor_account" do
    assert_difference('VendorAccount.count', -1) do
      delete :destroy, id: @vendor_account
    end

    assert_redirected_to vendor_accounts_path
  end
end
