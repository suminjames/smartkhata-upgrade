require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase
  setup do
    @bank_account = bank_accounts(:one)
    @bank = banks(:one)
  end

  # index
  test "unauthenticated users should get not get index" do
    get :index
    assert_response :redirect
  end
  test "authenticated user should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_accounts)
  end

  # new
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end
  test "authenticated user should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
  end

  # create
  test "should create a bank_account but not a duplicate one" do
    sign_in users(:user)
    assert_difference 'BankAccount.count', 1 do
      post :create, bank_account: {bank_id: @bank.id, account_number: 123,"default_for_sales"=>"1", "default_for_purchase"=>"1","ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
    end
    assert_redirected_to bank_account_path(assigns(:bank_account))

    assert_no_difference 'BankAccount.count' do
      post :create, bank_account: {bank_id: @bank.id, account_number: 123,"default_for_sales"=>"1", "default_for_purchase"=>"1","ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
    end
    assert_template 'bank_accounts/edit'
  end

  test "should not create a bank_account when not signed in" do
    assert_no_difference 'BankAccount.count' do
      post :create, bank_account: {bank_id: @bank.id, account_number: 123,"default_for_sales"=>"1", "default_for_purchase"=>"1","ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
    end
    assert_redirected_to new_user_session_path
  end

  # test "quux" do
  test "should not create a bank_account with invalid input" do
    sign_in users(:user)
    
    # imaginary bank id
    assert_no_difference 'BankAccount.count' do
      post :create, bank_account: {bank_id: 543210, account_number: 123, "default_for_sales"=>"1", "default_for_purchase"=>"1","ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0 }}
    end
    assert_response :success
    # assert_not flash.empty?

    # extra large opening balance -- THROWS ERROR <frontend>--
    assert_no_difference 'BankAccount.count' do
      post :create, bank_account: {bank_id: @bank.id, account_number: 123, "default_for_sales"=>"1", "default_for_purchase"=>"1","ledger_attributes" => { opening_blnc: 1234567890234567890, opening_blnc_type: 0} }
    end
    assert_response :success
    # assert_not flash.empty? 
  end

  # show
  test "for unauthenticated users should not show bank_account" do
    get :show, id: @bank_account
    assert_response :redirect
  end
  test "should show bank_account for authenticated user" do
    sign_in users(:user)
    get :show, id: @bank_account
    assert_response :success
  end

  # edit
  test "unauthenticated users should not get edit" do
    get :edit, id: @bank_account
    assert_response :redirect
  end
  test "authenticated users should get edit" do
    sign_in users(:user)
    get :edit, id: @bank_account
    assert_response :success
  end

  # update
  test "authenticated users should update bank_account" do
    sign_in users(:user)
    assert !@bank_account.default_for_sales
    patch :update, id: @bank_account, bank_account: { default_for_sales: "1" }
    assert_redirected_to bank_account_path(assigns(:bank_account))
    @bank_account.reload
    assert @bank_account.default_for_sales
  end
  test "unauthenticated users should not update bank_account" do
    assert !@bank_account.default_for_sales
    patch :update, id: @bank_account, bank_account: { default_for_sales: "1" }
    assert_redirected_to new_user_session_path
    @bank_account.reload
    assert !@bank_account.default_for_sales
  end

  # delete
  test "authenticated users should destroy bank_account" do
    sign_in users(:user)
    assert_difference 'BankAccount.count', -1 do
      delete :destroy, id: @bank_account
    end
    assert_redirected_to bank_accounts_path
  end
  test "unauthenticated users should not destroy bank_account" do
    assert_no_difference 'BankAccount.count' do
      delete :destroy, id: @bank_account
    end
    assert_redirected_to new_user_session_path
  end
end
