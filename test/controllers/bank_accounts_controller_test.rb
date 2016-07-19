require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase
  setup do
    @bank_account = bank_accounts(:one)
    @bank = banks(:one)
    @branch = branches(:one)
    @group = groups(:one)
    sign_in users(:user)
    @post_action = lambda { |acc_no|
      post :create, bank_account: {bank_id: @bank.id, account_number: acc_no, bank_branch: "foo", "default_for_receipt"=>"1", "default_for_payment"=>"1",
                                   "ledger_attributes"=>
                                      {"group_id"=> @group.id,
                                       "ledger_balances_attributes"=>
                                          [{"opening_balance"=>"9999",
                                             "opening_balance_type"=>"0",
                                             "branch_id"=> @branch.id
                                            }]
                                      }
                                  }
      assigns(:bank_account)
    }
    @assert_block_via_get = Proc.new { |action, get_with_id|
      if get_with_id
        get action, id: @bank_account
      else
        get action
      end
      assert_response :success
      assert_template "bank_accounts/#{action}"
      unless get_with_id
        instance_var = action == :new ? 'bank_account' : 'bank_accounts'
        assert_not_nil assigns(instance_var)
      end
    }
    @assert_block_via_patch = lambda { |user_type|
      assert @valid_bank_account.default_for_receipt
      patch :update, id: @valid_bank_account, bank_account: { default_for_receipt: "0" }
      @bank_account.reload
      if user_type == 'authenticated'
        assert_not @bank_account.default_for_receipt
        redirect_path = bank_account_path(assigns(:bank_account))
      else
        assert @bank_account.default_for_receipt
        redirect_path = new_user_session_path
      end
      assert_redirected_to redirect_path
    }
  end

  # index
  test "should get index" do
    @assert_block_via_get.call(:index)
  end

  # new
  test "should get new" do
    @assert_block_via_get.call(:new)
  end

  # create
  test "should create a bank_account" do
    assert_difference 'BankAccount.count', 1 do
      @post_action.call(123)
    end
    assert_redirected_to bank_account_path(assigns(:bank_account))
  end

  # briefly testing an invalid input- more in unit test
  # negative account number
  test "should not create a bank_account with invalid input" do
    assert_no_difference 'BankAccount.count' do
      @post_action.call(-123)
    end
    assert_response :success
    assert_template 'bank_accounts/new'
    assert_not_nil assigns(:bank_account)
    assert_match 'should be numeric or alphanumeric', response.body
    # simple_form does not use flash?
    # assert_not_nil flash[:error]
  end

  # show
  test "should show bank_account" do
    @assert_block_via_get.call(:show, true)
  end

  # edit
  test "should get edit" do
    @assert_block_via_get.call(:edit, true)
  end

  # update
  test "should update bank_account" do
    @valid_bank_account = @post_action.call(123)
    @assert_block_via_patch.call('authenticated')
  end

  # delete
  test "should delete bank_account" do
    assert_difference 'BankAccount.count', -1 do
      delete :destroy, id: @bank_account
    end
    assert_redirected_to bank_accounts_path
  end

# Unauthenticated tests: not specific to the controller
=begin
  test "unauthenticated users should get not get index" do
    get :index
    assert_redirected_to new_user_session_path
  end
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end
  test "unauthenticated users should not create a bank_account" do
    assert_no_difference 'BankAccount.count' do
      @post_action.call(123)
    end
    assert_redirected_to new_user_session_path
  end
  test "should not show bank_account to unauthenticated users " do
    get :show, id: @bank_account
    assert_redirected_to new_user_session_path
  end
  test "unauthenticated users should not get edit" do
    get :edit, id: @bank_account
    assert_redirected_to new_user_session_path
  end
  test "unauthenticated users should not update bank_account" do
    @assert_block_via_patch.call('unauthenticated')
  end
  test "unauthenticated users should not delete bank_account" do
    assert_no_difference 'BankAccount.count' do
      delete :destroy, id: @bank_account
    end
    assert_redirected_to new_user_session_path
  end
=end
end
