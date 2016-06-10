require 'test_helper'

class ClientAccountsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
    @client_account = client_accounts(:one)
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:client_account)
  end

  # Search by certain params maybe?
  test "should get index" do
    get :index
    assert_redirected_to client_accounts_path(search_by: "name")

    get :index, search_by: 'name'
    assert_response :success
    assert_not_nil assigns(:client_accounts)
  end

  test "should show client account" do
    get :show, id: @client_account
    assert_response :success
    assert_not_nil assigns(:client_account)
  end

  test "should get edit" do
    get :edit, id: @client_account
    assert_response :success
    assert_not_nil assigns(:client_account)
  end

  test "should create new" do
    assert_difference 'ClientAccount.count', 1 do
      post :create, client_account: {name: ''}
    end
    assert_redirected_to client_account_path(assigns(:client_account))
  end

  test "should update client account" do
    assert_not_equal 'Minitest', @client_account.name
    post :update, id: @client_account, client_account: {name: 'Minitest'}
    assert_redirected_to client_account_path(assigns(:client_account))
    assert_not_nil assigns(:client_account)
    @client_account.reload
    assert_equal 'Minitest', @client_account.name
  end

  test "should destroy client account" do
    assert_difference 'ClientAccount.count', -1 do
      post :destroy, id: @client_account
    end
    assert_redirected_to client_accounts_path
  end
end
