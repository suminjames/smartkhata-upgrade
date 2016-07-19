require 'test_helper'

class ClientAccountsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
    @client_account = client_accounts(:one)
    @block_assert = lambda{ |action|
      params = [:show, :edit].include?(action) ? {id: @client_account} : {}
      get action, params
      instance_var = action == :index ? :client_accounts : :client_account
      assert_response :success
      assert_template "client_accounts/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  # trying dynamic methods
  [:new, :index, :show, :edit].each do |action|
    define_method("test_should_get_#{action}") do
      @block_assert.call(action)
    end
  end

  # test "should get new" do
  #   @block_assert.call(:new)
  # end

  # test "should get index" do
  #   @block_assert.call(:index)
  # end

  # test "should show client account" do
  #   @block_assert.call(:show)
  # end

  # test "should get edit" do
  #   @block_assert.call(:edit)
  # end

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
