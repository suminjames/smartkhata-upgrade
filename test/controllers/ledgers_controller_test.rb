require 'test_helper'

class LedgersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @ledger = ledgers(:one)
    @group = groups(:one)
    @branch = branches(:one)
    @block_assert = lambda{ |action|
      instance_var = action == :index ? :ledgers : :ledger
      assert_response :success
      assert_template "ledgers/#{action}"
      assert_not_nil assigns(instance_var)
    }
  end

  test "should get index" do
    get :index
    @block_assert.call(:index)
  end

  test "should get new" do
    get :new
    @block_assert.call(:new)
  end

  test "should create ledger" do
    assert_difference 'Ledger.count', 1 do
      post :create, ledger: { name: 'foo', group_id: @group.id,
                              ledger_balances_attributes: [{opening_balance: '100', opening_balance_type: '0', branch_id: @branch.id}] }
    end
    assert_equal "Ledger was successfully created.", flash[:notice]
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
    patch :update, id: @ledger, ledger: { name: 'bar' , group_id: @group}
    assert_redirected_to ledger_path(assigns(:ledger))
    assert_equal "Ledger was successfully updated.", flash[:notice]
    @ledger.reload
    assert_equal @ledger.name, 'bar'
  end

  test "should update ledger" do
    assert_not_equal @ledger.name, 'bar'
    patch :update, id: @ledger, ledger: { name: 'bar' , group_id: @group}
    assert_redirected_to ledger_path(assigns(:ledger))
    assert_equal "Ledger was successfully updated.", flash[:notice]
    @ledger.reload
    assert_equal @ledger.name, 'bar'
  end

  #Disabled. A ledger should be ever be destroyed.
  test "should destroy ledger" do
    assert_difference 'Ledger.count', -1 do
      delete :destroy, id: @ledger
    end
    assert_equal "Ledger was successfully destroyed.", flash[:notice]
    assert_redirected_to ledgers_path
  end
end
