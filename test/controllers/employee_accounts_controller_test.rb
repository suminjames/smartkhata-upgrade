require 'test_helper'

class EmployeeAccountsControllerTest < ActionController::TestCase
  setup do
    @employee_account = employee_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employee_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employee_account" do
    assert_difference('EmployeeAccount.count') do
      post :create, employee_account: {  }
    end

    assert_redirected_to employee_account_path(assigns(:employee_account))
  end

  test "should show employee_account" do
    get :show, id: @employee_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @employee_account
    assert_response :success
  end

  test "should update employee_account" do
    patch :update, id: @employee_account, employee_account: {  }
    assert_redirected_to employee_account_path(assigns(:employee_account))
  end

  test "should destroy employee_account" do
    assert_difference('EmployeeAccount.count', -1) do
      delete :destroy, id: @employee_account
    end

    assert_redirected_to employee_accounts_path
  end
end
