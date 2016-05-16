require 'test_helper'

class ChequeEntriesControllerTest < ActionController::TestCase
  setup do
    @cheque_entry = cheque_entries(:one)
    @bank_account = bank_accounts(:one)
    @user = users(:user)
    @post_action = lambda { | acc_id, start_cheque_num, end_cheque_num |
      post :create, { bank_account_id: acc_id, start_cheque_number: start_cheque_num, end_cheque_number: end_cheque_num }
    }
    # @another_bank_account = bank_accounts(:two)
  end

  # index
  test "authenticated users should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_template 'cheque_entries/index'
    assert_not_nil assigns(:cheque_entries)
  end
  test "unauthenticated users should get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  # new
  test "authenticated users should get new" do
    sign_in @user
    get :new
    assert_response :success
    assert_template 'cheque_entries/new'
  end
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end

  # create
  test "authenticated users should create cheque_entry" do
    sign_in @user
    assert_difference 'ChequeEntry.count', 10 do
      @post_action.call(@bank_account.id, 1, 10)
    end
    assert_redirected_to cheque_entries_path(assigns(:cheque_entry))
  end

  test "unauthenticated users should not create cheque_entry" do
    assert_no_difference 'ChequeEntry.count' do
      @post_action.call(@bank_account.id, 1, 10)
    end
    assert_redirected_to new_user_session_path
  end

  # briefly testing invalid inputs- more in model test
  # imaginary bank account
  test "should not create cheque_entry with imaginary bank account" do
    sign_in @user
    assert_no_difference 'ChequeEntry.count' do
      @post_action.call(92649, 10, 15)
    end
    assert_not flash.empty?
    assert_template 'cheque_entries/new'
  end
  # at the time of creation, THIS TEST GENERATES uncaught ValidationError.
  test "should not create cheque_entry with negative cheque number" do
    sign_in @user
    assert_no_difference 'ChequeEntry.count' do
      @post_action.call(@bank_account.id, -245, -245)
    end
    assert_not flash.empty?
    assert_template 'cheque_entries/new'
  end
  # at the time of creation, THIS TEST GENERATES uncaught RangeError.
  test "should not create cheque_entry with very large cheque number" do
    sign_in @user
    assert_no_difference 'ChequeEntry.count' do
      @post_action.call(@bank_account.id, 10**15, 10**15)
    end
    assert_not flash.empty?
    assert_template 'cheque_entries/new'
  end

  # show
  test "should show cheque_entry to authenticated users" do
    sign_in @user
    get :show, id: @cheque_entry
    assert_response :success
    assert_template 'cheque_entries/show'
  end
  test "should not show cheque_entry to unauthenticated users" do
    get :show, id: @cheque_entry
    assert_redirected_to new_user_session_path
  end

=begin
  # Cheque editing not configured although action/view exists

  # edit
  test "authenticated users should get edit" do
    sign_in @user
    get :edit, id: @cheque_entry
    assert_response :success
  end
  test "unauthenticated users should not get edit" do
    get :edit, id: @cheque_entry
    assert_redirected_to new_user_session_path
  end

  # update
  test "authenticated users should update cheque_entry" do
    sign_in @user
    assert_equal @cheque_entry.bank_account.account_number, @bank_account.account_number
    patch :update, id: @cheque_entry, cheque_entry: { bank_account_id: @another_bank_account.id }
    assert_redirected_to cheque_entry_path(assigns(:cheque_entry))
    # check  the updated value?
    assert_equal @cheque_entry.bank_account.account_number, @another_bank_account.account_number
  end
  test "unauthenticated users should update cheque_entry" do
    assert_equal @cheque_entry.bank_account.account_number, @bank_account.account_number
    patch :update, id: @cheque_entry, cheque_entry: { bank_account_id: @another_bank_account.id }
    assert_redirected_to new_user_session_path
    # check the unchanged value?
    assert_equal @cheque_entry.bank_account.account_number, @bank_account.account_number
  end
  # INSERT UPDATE WITH INVALID INPUT
=end


  # delete
  test "authenticated users should delete cheque_entry" do
    sign_in @user
    assert_difference 'ChequeEntry.count', -1 do
      delete :destroy, id: @cheque_entry
    end
    assert_redirected_to cheque_entries_path
  end
  test "unauthenticated users should not delete cheque_entry" do
    assert_no_difference 'ChequeEntry.count' do
      delete :destroy, id: @cheque_entry
    end
    assert_redirected_to new_user_session_path
  end
end
