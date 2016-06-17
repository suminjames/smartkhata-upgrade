require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_template 'dashboard/index'
    assert_select 'h2.section-title', text: 'Dashboard'
    [:total_users, :amount, :purchase_bills_pending_count, :pending_voucher_approve_count].each do |var|
      assert_not_nil assigns(var)
    end
  end

end
