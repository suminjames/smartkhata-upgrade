require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase
  setup do
    @bank_account = bank_accounts(:one)
    @bank = banks(:one)
    @user = users(:user)
    @post_action = lambda { |acc_no|
      post :create, bank_account: {bank_id: @bank.id, account_number: acc_no, "default_for_sales"=>"1", "default_for_purchase"=>"1",
                                   "ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
    }
    @block_assert_via_login_and_get = lambda { |action|
      sign_in @user
      get action
      assert_response :success
      assert_template "bank_accounts/#{action}"
      instance_var_name = action == :new ? 'bank_account' : 'bank_accounts'
      assert_not_nil assigns(instance_var_name)
    }
    @block_assert_via_login_and_patch = lambda { |user_type|
      sign_in @user
      assert_not @bank_account.default_for_sales
      patch :update, id: @bank_account, bank_account: { default_for_sales: "1" }
      @bank_account.reload
      if user_type == 'authenticated'
        assert @bank_account.default_for_sales
        redirect_path = bank_account_path(assigns(:bank_account))
      else
        assert_not @bank_account.default_for_sales
        redirect_path = new_user_session_path
      end
        assert_redirected_to redirect_path
    }
  end

  # index
  test "authenticated user should get index" do
    @block_assert_via_login_and_get.call(:index)
  end
  test "unauthenticated users should get not get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  # new
  test "authenticated users should get new" do
    @block_assert_via_login_and_get.call(:new)
  end
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end

  # create
  test "authenticated users should create a bank_account" do
    sign_in @user
    assert_difference 'BankAccount.count', 1 do
      @post_action.call(123)
    end
    assert_redirected_to bank_account_path(assigns(:bank_account))
  end

  test "unauthenticated users should not create a bank_account" do
    assert_no_difference 'BankAccount.count' do
      @post_action.call(123)
    end
    assert_redirected_to new_user_session_path
  end

  # briefly testing an invalid input- more in model test
  # negative account number
  test "should not create a bank_account with invalid input" do
    sign_in @user
    assert_no_difference 'BankAccount.count' do
      @post_action.call(-123)
    end
    assert_response :success
    assert_template 'bank_accounts/new'
    assert_not_nil assigns(:bank_account)
    # Flash appears to be empty- has it something to do with respond_to format ?
    # Not a problem in the frontend!
    assert_not flash.empty?, "No idea why Flash APPEARS empty!"
  end

  # show
  test "should show bank_account to authenticated user" do
    sign_in @user
    get :show, id: @bank_account
    assert_response :success
    assert_template 'bank_accounts/show'
  end
  test "should not show bank_account to unauthenticated users " do
    get :show, id: @bank_account
    assert_redirected_to new_user_session_path
  end

  # edit
  test "unauthenticated users should not get edit" do
    get :edit, id: @bank_account
    assert_redirected_to new_user_session_path
  end
  test "authenticated users should get edit" do
    sign_in @user
    get :edit, id: @bank_account
    assert_response :success
    assert_template 'bank_accounts/edit'
  end

<<<<<<< HEAD
  # update
  test "authenticated users should update bank_account" do
    @block_assert_via_login_and_patch.call('authenticated')
  end
  test "unauthenticated users should not update bank_account" do
    @block_assert_via_login_and_patch.call('unauthenticated')
=======

  test "allowed users should update bank_account" do
    sign_in users(:user)
    patch :update, id: @bank_account, bank_account: {default_for_receipt: false }
    assert_redirected_to bank_account_path(assigns(:bank_account))
>>>>>>> master
  end

  # delete
  test "authenticated users should delete bank_account" do
    sign_in @user
    assert_difference 'BankAccount.count', -1 do
      delete :destroy, id: @bank_account
    end
    assert_redirected_to bank_accounts_path
  end
  test "unauthenticated users should not delete bank_account" do
    assert_no_difference 'BankAccount.count' do
      delete :destroy, id: @bank_account
    end
    assert_redirected_to new_user_session_path
  end
end
