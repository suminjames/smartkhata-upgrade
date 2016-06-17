=begin
require 'test_helper'

class EmployeeLedgerAssociationsControllerTest < ActionController::TestCase
  setup do
    @employee_ledger_association = employee_ledger_associations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employee_ledger_associations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employee_ledger_association" do
    assert_difference('EmployeeLedgerAssociation.count') do
      post :create, employee_ledger_association: {  }
    end

    assert_redirected_to employee_ledger_association_path(assigns(:employee_ledger_association))
  end

  test "should show employee_ledger_association" do
    get :show, id: @employee_ledger_association
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @employee_ledger_association
    assert_response :success
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
=end