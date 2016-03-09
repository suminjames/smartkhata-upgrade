require 'test_helper'

class ChequeEntriesControllerTest < ActionController::TestCase
  setup do
    @cheque_entry = cheque_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cheque_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cheque_entry" do
    assert_difference('ChequeEntry.count') do
      post :create, cheque_entry: {  }
    end

    assert_redirected_to cheque_entry_path(assigns(:cheque_entry))
  end

  test "should show cheque_entry" do
    get :show, id: @cheque_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cheque_entry
    assert_response :success
  end

  test "should update cheque_entry" do
    patch :update, id: @cheque_entry, cheque_entry: {  }
    assert_redirected_to cheque_entry_path(assigns(:cheque_entry))
  end

  test "should destroy cheque_entry" do
    assert_difference('ChequeEntry.count', -1) do
      delete :destroy, id: @cheque_entry
    end

    assert_redirected_to cheque_entries_path
  end
end
