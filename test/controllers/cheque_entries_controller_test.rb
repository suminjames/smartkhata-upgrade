require 'test_helper'

class ChequeEntriesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @cheque_entry = cheque_entries(:one)
    @bank_account = bank_accounts(:one)
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
    @assert_block_via_get.call(:index)
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
    assert_redirected_to cheque_entries_path
  end

  # briefly testing invalid inputs- more in unit test
  # Negative cheque number
  test "should not create cheque_entry with negative cheque number" do
    @assert_block_via_invalid_post.call(@bank_account.id, -245, -245)
  end

  # show
  test "should show cheque_entry to authenticated users" do
    get :show, id: @cheque_entry
    assert_response :success
    assert_template 'cheque_entries/show'
  end

=begin
  # Cheque editing & delete to be removed from controller: not configured although action/view exists

  # edit
  test "should get edit" do
    get :edit, id: @cheque_entry
    assert_response :success
  end

  # update
  test "should update cheque_entry" do
    assert_equal @cheque_entry.bank_account.account_number, @bank_account.account_number
    patch :update, id: @cheque_entry, cheque_entry: { bank_account_id: @another_bank_account.id }
    assert_redirected_to cheque_entry_path(assigns(:cheque_entry))
    # check  the updated value?
    assert_equal @cheque_entry.bank_account.account_number, @another_bank_account.account_number
  end

  # delete
  test "should delete cheque_entry" do
    assert_difference 'ChequeEntry.count', -1 do
      delete :destroy, id: @cheque_entry
    end
    assert_redirected_to cheque_entries_path
  end
=end

end
