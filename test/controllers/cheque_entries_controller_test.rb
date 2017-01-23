require 'test_helper'

class ChequeEntriesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @cheque_entry = cheque_entries(:one)
    @bank_account = bank_accounts(:one)
    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    set_branch_id 1

    @post_action = lambda { | bank_account_id, start_cheque_num, end_cheque_num |
      post :create, { bank_account_id: bank_account_id, start_cheque_number: start_cheque_num, end_cheque_number: end_cheque_num }
    }
    # @another_bank_account = bank_accounts(:two)
    @assert_block_via_get = lambda { |action|
      get action
      assert_response :success
      assert_template "cheque_entries/#{action}"
      assert_not_nil assigns(:cheque_entries) if action == :index
    }
    @assert_block_via_invalid_post = lambda { |bank_account_id, start_cheque_num, end_cheque_num|
      assert_no_difference 'ChequeEntry.count' do
        @post_action.call(bank_account_id, start_cheque_num, end_cheque_num)
      end
      assert_not flash.empty?
      assert_template 'cheque_entries/new'
    }
  end

  # index
  test "should get index" do
    get :index
    assert_redirected_to cheque_entries_path('filterrific[by_cheque_entry_status]':'assigned')
  end

  # new
  test "should get new" do
    @assert_block_via_get.call(:new)
  end

  # create
  test "should create cheque_entry" do
    assert_difference 'ChequeEntry.count', 10 do
      @post_action.call(@bank_account.id, 1, 10)
    end
    assert_redirected_to cheque_entries_path('filterrific[by_bank_account_id]':@bank_account.id)
  end

  # briefly testing invalid inputs- more in unit test
  # Negative cheque number
  test "should not create cheque_entry with negative cheque number" do
    @assert_block_via_invalid_post.call(@bank_account.id, -245, -245)
  end

  # show
  test "should show cheque_entry" do
    get :show, id: @cheque_entry
    assert_response :success
    assert_template 'cheque_entries/show'
  end

end
