require 'test_helper'

class LedgersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @ledger = ledgers(:one)
    @block_assert = lambda{ |action|
      instance_var = action == :index ? :ledgers : :ledger
      assert_response :success
      assert_template "ledgers/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  test "should get index" do
    get :index
    assert_redirected_to ledgers_path(search_by: 'ledger_name')
    get :index, search_by: 'ledger_name'
    @block_assert.call(:index)
  end

  test "should get new" do
    get :new
    @block_assert.call(:new)
  end

  test "should create ledger" do
    assert_difference 'Ledger.count', 1 do
      post :create, ledger: { name: 'foo' }
    end
    assert_redirected_to ledger_path(assigns(:ledger))
  end

  test "should show ledger" do
    get :show, id: @ledger
    @block_assert.call(:show)
  end

  test "should get edit" do
    get :edit, id: @ledger
    @block_assert.call(:edit)
  end

  test "should update ledger" do
    assert_not_equal @ledger.name, 'bar'
    patch :update, id: @ledger, ledger: { name: 'bar' }
    assert_redirected_to ledger_path(assigns(:ledger))
    @ledger.reload
    assert_equal @ledger.name, 'bar'
  end

  #Disabled. A ledger should be ever be destroyed.
  test "should destroy ledger" do
    assert_difference 'Ledger.count', -1 do
      delete :destroy, id: @ledger
    end
    assert_redirected_to ledgers_path
  end
end
