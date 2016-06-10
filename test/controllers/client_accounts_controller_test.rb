require 'test_helper'

class ClientAccountsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
    @client_account = client_accounts(:one)
    @block_assert = lambda{ |action|
      instance_var = action == :index ? :client_accounts : :client_account
      assert_response :success
      assert_template "client_accounts/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  test "should get new" do
    get :new
    @block_assert.call(:new)
  end

  # Search by certain params maybe?
  test "should get index" do
    get :index
    assert_redirected_to client_accounts_path(search_by: "name")
    get :index, search_by: 'name'
    @block_assert.call(:index)
  end

  test "should show client account" do
    get :show, id: @client_account
    @block_assert.call(:show)
  end

  test "should get edit" do
    get :edit, id: @client_account
    @block_assert.call(:edit)
  end

  test "should create new" do
    assert_difference 'ClientAccount.count', 1 do
      post :create, client_account: {name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                     address1_perm: 'baz', city_perm: 'alpha', state_perm: 'beta', country_perm: 'gamma'}
    end
    assert_redirected_to client_account_path(assigns(:client_account))
  end

  test "should update client account" do
    assert_not_equal 'Minitest', @client_account.name
    patch :update, id: @client_account, client_account: {name: 'Minitest'}
    assert_redirected_to client_account_path(assigns(:client_account))
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
