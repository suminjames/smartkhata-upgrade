
require 'test_helper'

class ShareTransactionsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @request.host = 'trishakti.lvh.me'
    @share_transaction = share_transactions(:one)
    @set_session = lambda { |transaction|
      voucher = Voucher.unscoped.find(transaction.voucher_id)
      set_fy_code_and_branch_from voucher
    }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:share_transactions)
  end

  test "should create share_transaction" do
    assert_difference 'ShareTransaction.count' do
      post :create, share_transaction: { base_price: 10 }
    end
    assert_redirected_to share_transaction_path(assigns(:share_transaction))
  end

  test "should soft delete share_transaction" do
    assert_nil @share_transaction.deleted_at
    # does not hard delete
    assert_no_difference 'ShareTransaction.count' do
      delete :destroy, id: @share_transaction, format: 'json' # accepts only json
    end
    @share_transaction.reload
    assert_not_nil @share_transaction.deleted_at
  end

  #
  # deal cancel & pending deal (custom actions)
  #
  test "should get deal cancel, queue and approve one" do
    transaction = @share_transaction
    @set_session.call(transaction)

    assert_equal 'no_deal_cancel', transaction.transaction_cancel_status
    # Deal Cancel
    # first step: goto deal cancel path
    get :deal_cancel
    assert_response :success
    assert_match 'Search the Transaction for Cancelling', response.body
    assert_select 'form[action="/share_transactions/deal_cancel"]' do
      assert_select 'input[type="text"][name="contract_no"]'
      assert_select 'select[name="transaction_type"]'
      assert_select 'input[type="submit"][value="Search"]'
    end

    # second step: search by contract_no && transaction_type
    get :deal_cancel, contract_no: transaction.contract_no, transaction_type: transaction.transaction_type
    assert_response :success
    assert_match 'Verify the share transaction before cancelling', response.body
    assert_select 'form[action="/share_transactions/deal_cancel"]' do
      assert_select 'input[type="hidden"][name="id"][value=?]', transaction.id.to_s
      assert_select 'input[type="submit"][value="Process Deal Cancel"]'
    end

    # third step: queue deal cancel
    get :deal_cancel, id: transaction.id
    assert_contains 'Deal cancelled successfully', flash[:notice]
    assert_redirected_to deal_cancel_share_transactions_path

    transaction.reload
    assert_equal 'deal_cancel_pending', transaction.transaction_cancel_status

    # Pending Deal Cancel
    # fourth step: goto pending deal cancel path
    get :pending_deal_cancel
    ['date.to_s', 'contract_no.to_s', 'client_account.name', 'quantity.to_s'].each do |attr|
      expected_data = attr.include?('.') ? transaction.send(attr.split('.')[0]).send(attr.split('.')[1]) : transaction.send(attr)
      # expected_data = transaction.send(attr)
      assert_match expected_data, response.body
    end
    ['approve', 'reject'].each do |action|
      assert_select 'a[href=?]', pending_deal_cancel_share_transactions_path(approval_action: action, id: transaction.id.to_s), text: action.capitalize
    end

    # Fifth step: Approve deal cancel
    get :pending_deal_cancel, approval_action: 'approve', id: transaction.id.to_s
    assert_response :success
    assert_contains 'Deal cancel approved successfully', flash[:notice]

    transaction.reload
    assert_equal 'deal_cancel_complete', transaction.transaction_cancel_status
  end

  test "should reject deal cancel" do
    # Test only briefly for #reject
    transaction = share_transactions(:two)
    @set_session.call(transaction)
    assert_equal 'no_deal_cancel', transaction.transaction_cancel_status
    # queue deal cancel
    get :deal_cancel, id: transaction.id
    # reject
    get :pending_deal_cancel, approval_action: 'reject', id: transaction.id.to_s
    assert_contains 'Deal cancel rejected successfully', flash[:notice]
    assert_response :success

    transaction.reload
    assert_equal 'no_deal_cancel', transaction.transaction_cancel_status
  end

  # # Irrelevant actions
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should show share_transaction" do
  #   get :show, id: @share_transaction
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get :edit, id: @share_transaction
  #   assert_response :success
  # end

  # test "should update share_transaction" do
  #   patch :update, id: @share_transaction, share_transaction: { base_price: 200 }
  #   assert_redirected_to share_transaction_path(assigns(:share_transaction))
  # end
end
