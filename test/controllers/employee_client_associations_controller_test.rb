=begin
require 'test_helper'

class EmployeeClientAssociationsControllerTest < ActionController::TestCase
  setup do
    @employee_client_association = employee_client_associations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employee_client_associations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employee_client_association" do
    assert_difference('EmployeeClientAssociation.count') do
      post :create, employee_client_association: {  }
    end

    assert_redirected_to employee_client_association_path(assigns(:employee_client_association))
  end

  test "should show employee_client_association" do
    get :show, id: @employee_client_association
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @employee_client_association
    assert_response :success
  end

  test "should update employee_client_association" do
    patch :update, id: @employee_client_association, employee_client_association: {  }
    assert_redirected_to employee_client_association_path(assigns(:employee_client_association))
  end

  test "should destroy employee_client_association" do
    assert_difference('EmployeeClientAssociation.count', -1) do
      delete :destroy, id: @employee_client_association
    end

    assert_redirected_to employee_client_associations_path
  end
end
=end