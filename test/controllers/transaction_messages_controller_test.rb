require 'test_helper'

class TransactionMessagesControllerTest < ActionController::TestCase
  setup do
    @transaction_message = transaction_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transaction_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transaction_message" do
    assert_difference('TransactionMessage.count') do
      post :create, transaction_message: { bill_id: @transaction_message.bill_id, client_account_id: @transaction_message.client_account_id, email_status: @transaction_message.email_status, sms_message: @transaction_message.sms_message, sms_status: @transaction_message.sms_status, transaction_date: @transaction_message.transaction_date }
    end

    assert_redirected_to transaction_message_path(assigns(:transaction_message))
  end

  test "should show transaction_message" do
    get :show, id: @transaction_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transaction_message
    assert_response :success
  end

  test "should update transaction_message" do
    patch :update, id: @transaction_message, transaction_message: { bill_id: @transaction_message.bill_id, client_account_id: @transaction_message.client_account_id, email_status: @transaction_message.email_status, sms_message: @transaction_message.sms_message, sms_status: @transaction_message.sms_status, transaction_date: @transaction_message.transaction_date }
    assert_redirected_to transaction_message_path(assigns(:transaction_message))
  end

  test "should destroy transaction_message" do
    assert_difference('TransactionMessage.count', -1) do
      delete :destroy, id: @transaction_message
    end

    assert_redirected_to transaction_messages_path
  end
end
