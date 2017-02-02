require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  def setup
    @request.host = 'trishakti.lvh.me'
    set_branch_id 1
    # sign_in users(:user)
  end

  def sign_in_non_client_user
    sign_in users(:user)
  end

  def sign_in_client_user
    sign_in users(:client_user)
  end

  test "non-client login should get dashboard index" do
    sign_in_non_client_user
    get :index
    assert_response :success
    assert_template 'dashboard/index'
    assert_select 'h2.section-title', text: 'Dashboard'
    [:total_users, :amount, :purchase_bills_pending_count, :pending_voucher_approve_count].each do |var|
      assert_not_nil assigns(var)
    end
  end

  test "client login should get dashboard client index" do
    sign_in_client_user
    create(:client_account, :user_id => users(:client_user).id)
    get :client_index
    assert_template 'dashboard/client_index'
    assert_response :success
    instance_var_array = assigns(:clients_info_arr)
    instance_var_array.each do |client_info_hash|
      client_info_hash.each do |key, val|
        assert_not_nil val
      end
    end
  end

  test "non-client users should not be able to access client dashboard" do
    sign_in_non_client_user
    get :client_index
    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "client users should not be able to access non-client dashboard" do
    sign_in_client_user
    get :index
    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end
end
