=begin
require 'test_helper'

class ShareTransactionsControllerTest < ActionController::TestCase
  setup do
    @share_transaction = share_transactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:share_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create share_transaction" do
    assert_difference('ShareTransaction.count') do
      post :create, share_transaction: {  }
    end

    assert_redirected_to share_transaction_path(assigns(:share_transaction))
  end

  test "should show share_transaction" do
    get :show, id: @share_transaction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @share_transaction
    assert_response :success
  end

  test "should update share_transaction" do
    patch :update, id: @share_transaction, share_transaction: {  }
    assert_redirected_to share_transaction_path(assigns(:share_transaction))
  end

  test "should destroy share_transaction" do
    assert_difference('ShareTransaction.count', -1) do
      delete :destroy, id: @share_transaction
    end

    assert_redirected_to share_transactions_path
  end
end
=end