require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user)
    @order = orders(:one)
    @block_assert = lambda{ |action|
      params =  action == :show ? {id: @order} : {search_by: 'client_name'}
      get action, params
      instance_var = action == :index ? :orders : :order
      assert_response :success
      assert_template "orders/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  test "should get index" do
    get :index
    assert_redirected_to orders_path(search_by: 'client_name')
    @block_assert.call(:index)
  end

  test "should get show" do
    @block_assert.call(:show)
  end
end
