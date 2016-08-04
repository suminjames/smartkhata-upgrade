require 'test_helper'

class TransactionMessagesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @request.host = 'trishakti.lvh.me'
    @transaction_message = transaction_messages(:one)
    @another_transaction_message = transaction_messages(:two)
  end

  test "should get index" do
    # debugger
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
    deletable_transaction_message = transaction_messages(:three)
    assert_difference('TransactionMessage.count', -1) do
      delete :destroy, id: deletable_transaction_message
    end
    assert_redirected_to transaction_messages_path
  end

  # testing custom methods # send_mail
  # test "should send email" do
  #   assert_difference('ActionMailer::Base.deliveries.size', 1) do
  #     # generates redis (connection refused) error
  #     post :send_email, transaction_message_ids: [@transaction_message.id, @another_transaction_message.id]
  #   end
  # end
end
