require 'test_helper'

class EmployeeAccountsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @employee_account = employee_accounts(:one)
    @block_assert = lambda{ |action|
      instance_var = action == :index ? :employee_accounts : :employee_account
      assert_response :success
      assert_template "employee_accounts/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  test "should get index" do
    get :index
    assert_redirected_to employee_accounts_path(search_by: 'name')
    get :index, search_by: 'name'
    @block_assert.call(:index)
  end

  test "should get new" do
    get :new
    @block_assert.call(:new)
  end

  test "should create employee_account" do
    assert_difference 'EmployeeAccount.count', 1 do
      post :create, employee_account: { name: 'Calypso Papa', email: 'calypso@example.com' }
    end
    assert_redirected_to employee_account_path(assigns(:employee_account))
  end

  test "should show employee_account" do
    get :show, id: @employee_account
    @block_assert.call(:show)
  end

  test "should get edit" do
    get :edit, id: @employee_account
    @block_assert.call(:edit)
  end

  test "should update employee_account" do
    assert_not_equal 'Minitest', @employee_account.name
    patch :update, id: @employee_account, edit_type: 'create_or_update', employee_account: { name: 'Minitest' }
    assert_redirected_to employee_account_path(assigns(:employee_account))
    @employee_account.reload
    assert_equal 'Minitest', @employee_account.name
  end

  test "should destroy employee_account" do
    assert_difference 'EmployeeAccount.count', -1 do
      delete :destroy, id: @employee_account
    end
    assert_redirected_to employee_accounts_path
  end
end
