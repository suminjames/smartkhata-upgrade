require 'test_helper'

class ChequeEntriesControllerTest < ActionController::TestCase
  setup do
    @cheque_entry = cheque_entries(:one)
    @bank_account = bank_accounts(:one)
  end

  # index
  test "authenticated users should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:cheque_entries)
  end
  test "unauthenticated users should get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  # new
  test "authenticated users should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
    # assert_not_nil assigns(:cheque_entry)
  end
  test "unauthenticated users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end

  # create
  test "authenticated users should create cheque_entry" do
    sign_in users(:user)
    assert_difference 'ChequeEntry.count', 10 do
      post :create, { bank_account_id: @bank_account.id, start_cheque_number: 1, end_cheque_number: 10 }
    end
    assert_redirected_to cheque_entries_path()
  end
  test "unauthenticated users should not create cheque_entry" do
    assert_no_difference 'ChequeEntry.count' do
      post :create, { bank_account_id: @bank_account.id, start_cheque_number: 1, end_cheque_number: 10 }
    end
    assert_redirected_to new_user_session_path
  end

  # INSERT CREATE WITH INVALID INPUT

  # show
  test "should show cheque_entry to authenticated users" do
    sign_in users(:user)
    get :show, id: @cheque_entry
    assert_response :success
  end
  test "should not show cheque_entry to unauthenticated users" do
    get :show, id: @cheque_entry
    assert_redirected_to new_user_session_path
  end

  # edit
  test "authenticated users should get edit" do
    sign_in users(:user)
    get :edit, id: @cheque_entry
    assert_response :success
  end
  test "unauthenticated users should not get edit" do
    get :edit, id: @cheque_entry
    assert_redirected_to new_user_session_path
  end

  # update
  test "authenticated users should update cheque_entry" do
    sign_in users(:user)
    patch :update, id: @cheque_entry, cheque_entry: { bank_account_id: @bank_account.id }
    assert_redirected_to cheque_entry_path(assigns(:cheque_entry))
    # check  the updated value?
  end
  test "unauthenticated users should update cheque_entry" do
    patch :update, id: @cheque_entry, cheque_entry: { bank_account_id: @bank_account.id }
    assert_redirected_to new_user_session_path
    # check the unchanged value?
  end

  # INSERT UPDATE WITH INVALID INPUT

  # destroy
  test "authenticated users should destroy cheque_entry" do
    sign_in users(:user)
    assert_difference 'ChequeEntry.count', -1 do
      delete :destroy, id: @cheque_entry
    end
    assert_redirected_to cheque_entries_path
  end
  test "unauthenticated users should not destroy cheque_entry" do
    assert_no_difference 'ChequeEntry.count' do
      delete :destroy, id: @cheque_entry
    end
    assert_redirected_to new_user_session_path
  end
end
