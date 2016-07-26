
require 'test_helper'

class EmployeeLedgerAssociationsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @employee_ledger_association = employee_ledger_associations(:one)
    @block_assert = lambda{ |action|
      params = [:show, :edit].include?(action) ? {id: @employee_ledger_association} : {}
      get action, params
      instance_var = action == :index ? :employee_ledger_associations : :employee_ledger_association
      assert_response :success
      assert_template "employee_ledger_associations/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  test "should get index" do
    @block_assert.call(:index)
  end

  test "should get new" do
    @block_assert.call(:new)
  end

  test "should create employee_ledger_association" do
    assert_difference('EmployeeLedgerAssociation.count') do
      post :create, employee_ledger_association: {  }
    end
    assert_redirected_to employee_ledger_association_path(assigns(:employee_ledger_association))
  end

  test "should show employee_ledger_association" do
    @block_assert.call(:show)
  end

  test "should get edit" do
    @block_assert.call(:edit)
  end

  test "should update employee_ledger_association" do
    patch :update, id: @employee_ledger_association, employee_ledger_association: {  }
    assert_redirected_to employee_ledger_association_path(assigns(:employee_ledger_association))
  end

  test "should destroy employee_ledger_association" do
    assert_difference('EmployeeLedgerAssociation.count', -1) do
      delete :destroy, id: @employee_ledger_association
    end
    assert_redirected_to employee_ledger_associations_path
  end
end
