require 'test_helper'

class ClientAccountsControllerTest < ActionController::TestCase
  def setup
    @request.host = 'trishakti.lvh.me'
    set_branch_id 1
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

  # Trying dynamic methods (meta programming)
  [:new, :index, :show, :edit].each do |action|
    define_method("test_should_get_#{action}") do
      @block_assert.call(action)
    end
  end

  test "should not create new client without branch assignment for tenant which has multiple branch" do
    assert_difference 'ClientAccount.count', 0 do
      post :create, client_account: {name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                     address1_perm: 'baz', city_perm: 'alpha', state_perm: 'beta', country_perm: 'gamma' }
    end
    assert_template :new
    client_account = assigns(:client_account)
    assert_not_empty client_account.errors
  end

  test "should create new client with branch assignment for tenant which has multiple branch" do
    assert_difference 'ClientAccount.count', 1 do
      post :create, client_account: {name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                     address1_perm: 'baz', city_perm: 'alpha', state_perm: 'beta', country_perm: 'gamma', branch_id: branches(:one).id}
    end
    client_account = assigns(:client_account)
    assert_redirected_to client_account_path(client_account)
    assert_equal branches(:one).id, client_account.branch_id
    assert_redirected_to client_account_path(assigns(:client_account))
  end


  test "should create new client without branch assignment for tenant which has single branch" do
    branches(:two).delete
    assert_difference 'ClientAccount.count', 1 do
      post :create, client_account: {name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                     address1_perm: 'baz', city_perm: 'alpha', state_perm: 'beta', country_perm: 'gamma' }
    end
    client_account = assigns(:client_account)
    assert_redirected_to client_account_path(client_account)
    assert_equal branches(:one).id, client_account.branch_id
  end

  test "should create new client with branch assignment for tenant which has single branch" do
    branches(:two).delete
    assert_difference 'ClientAccount.count', 1 do
      post :create, client_account: {name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                   address1_perm: 'baz', city_perm: 'alpha', state_perm: 'beta', country_perm: 'gamma', branch_id: branches(:one).id}
    end
    client_account = assigns(:client_account)
    assert_redirected_to client_account_path(client_account)
    assert_equal branches(:one).id, client_account.branch_id
  end

  test "should update client account" do
    assert_not_equal 'Minitest', @client_account.name
    patch :update, id: @client_account, client_account: {name: 'Minitest', branch_id: branches(:one).id}
    assert_redirected_to client_account_path(assigns(:client_account))
    @client_account.reload
    assert_equal 'Minitest', @client_account.name
  end

  test "should destroy client account" do
    deletable_client_account = client_accounts(:three)
    assert_difference 'ClientAccount.count', -1 do
      post :destroy, id: deletable_client_account
    end
    assert_redirected_to client_accounts_path
  end

  test "logged in client user should be able to see associated client's show" do
    sign_in users(:client_user)
    @client_account = create(
        :client_account,
        :user_id => users(:client_user).id,
        :branch_id => 1)
    params = {id: @client_account.id}
    get :show, params
    assert_response :success
    assert_template "client_accounts/show"
    assert_select 'div.highlighted-box',
                  /Please contact .+ if you need to make changes to the information in this page./
    assert_select "div.stick-to-bottom",
                  {count: 0, text: "Edit"},
                  "This page must contain no anchors that say Edit"
    assert_not_nil assigns(:client_account)
  end

  test "logged in client user should not be able to see unassociated client's show" do
    sign_in users(:client_user)
    create(:client_account, :user_id => users(:client_user).id, :branch_id => 1)
    @client_account =  create(:client_account, :branch_id => 1)
    params = {id: @client_account.id}
    get :show, params
    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

end
