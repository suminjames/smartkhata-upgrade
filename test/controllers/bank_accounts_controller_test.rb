require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase
  setup do
    @bank_account = bank_accounts(:one)
    @bank = banks(:one)
  end

  test "unauthenticated users should get redirect" do
    get :index
    assert_response :redirect
  end

  test "allowed user should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_accounts)
  end

  test "unauthenticated users should not get new" do
    get :new
    assert_response :redirect
  end

  test "allowed user should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
  end

  # TODO This test is failing and i dont know why
  test "should create bank_account" do
    sign_in users(:user)
    assert_difference('BankAccount.count') do
      post :create, bank_account: {bank_id: @bank.id, account_number: 123,"default_for_sales"=>"1", "default_for_purchase"=>"1","ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
      puts response
    end

    assert_redirected_to bank_account_path(assigns(:bank_account))
  end

  test "for unauthenticated users should not show bank_account" do
    get :show, id: @bank_account
    assert_response :redirect
  end
  test "should show bank_account for allowed user" do
    sign_in users(:user)
    get :show, id: @bank_account
    assert_response :success
  end

  test "unauthenticated users should not get edit" do
    get :edit, id: @bank_account
    assert_response :redirect
  end
  test "allowed users should get edit" do
    sign_in users(:user)
    get :edit, id: @bank_account
    assert_response :success
  end


  test "allowed users should update bank_account" do
    sign_in users(:user)
    patch :update, id: @bank_account, bank_account: { default_for_sales: false }
    assert_redirected_to bank_account_path(assigns(:bank_account))
  end

  test "should destroy bank_account" do
    sign_in users(:user)
    assert_difference('BankAccount.count', -1) do
      delete :destroy, id: @bank_account
    end

    assert_redirected_to bank_accounts_path
  end
end
