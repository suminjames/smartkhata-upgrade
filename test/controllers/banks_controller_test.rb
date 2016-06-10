require 'test_helper'

class BanksControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @bank = banks(:one)
    @post_action = lambda {
      post :create, bank: { address: 'utopia', bank_code: 'TBH', contact_no: '999999999', name: 'The Bank' }
    }
    @destroy_action = lambda { delete :destroy, id: @bank }
    @assert_block_via_login_and_get = Proc.new { |action, get_with_id|
      if get_with_id
        get action, id: @bank
      else
        get action
      end
      assert_response :success
      assert_template "banks/#{action}"
      unless get_with_id
        instance_var = action == :new ? 'bank' : 'banks'
        assert_not_nil assigns(instance_var)
      end
    }
    @assert_block_via_login_and_patch = lambda { |test_type|
      # sign_in @user if test_type == 'valid'
      assert_equal @bank.bank_code, 'MyString'
      patch :update, id: @bank, bank: {bank_code: 'SomeAnotherRandomString'}

      expected_bank_code, redirect_path = case test_type
      when 'valid'
        ['SomeAnotherRandomString', bank_path(assigns(:bank))]
      else
        ['MyString', new_user_session_path]
      end
      assert_redirected_to redirect_path
      @bank.reload
      assert_equal expected_bank_code, @bank.bank_code
    }
  end

  test "should get index" do
    @assert_block_via_login_and_get.call(:index)
  end

  test "should get new" do
    @assert_block_via_login_and_get.call(:new)
  end

  test "should create bank" do
    assert_difference 'Bank.count', 1 do
      @post_action.call
    end
    assert_redirected_to bank_path(assigns(:bank))
  end

  test "should show bank" do
    @assert_block_via_login_and_get.call(:show, true)
  end

  test "should get edit" do
    @assert_block_via_login_and_get.call(:edit, true)
  end

  test "should update bank" do
    @assert_block_via_login_and_patch.call('valid')
  end

=begin
  # destroy not configured
  test "should destroy bank" do
    sign_in @user
    assert_difference 'Bank.count', -1 do
      @destroy_action.call
    end
    assert_redirected_to banks_path
  end
=end

end
