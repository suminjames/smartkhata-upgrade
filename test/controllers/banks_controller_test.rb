require 'test_helper'

class BanksControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @bank = banks(:one)
    @post_action = lambda {
      post :create, bank: { address: 'utopia', bank_code: 'TBH', contact_no: '999999999', name: 'The Bank' }
    }
    @destroy_action = lambda { delete :destroy, id: @bank }
    @assert_block_via_login_and_get = Proc.new { |action, get_with_id|
      sign_in @user
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
      sign_in @user if test_type == 'valid'
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

  test "unauthorized users should not get index" do
    get :index
    assert_redirected_to new_user_session_path
  end

  test "authorized users should get index" do
    @assert_block_via_login_and_get.call(:index)
  end

  test "unauthorized users should not get new" do
    get :new
    assert_redirected_to new_user_session_path
  end

  test "authorized users should get new" do
    @assert_block_via_login_and_get.call(:new)
  end

  test "unauthorized users should not create bank" do
    assert_no_difference 'Bank.count' do
      @post_action.call
    end
    assert_redirected_to new_user_session_path
  end

  test "authorized users should create bank" do
    sign_in @user
    assert_difference 'Bank.count', 1 do
      @post_action.call
    end
    assert_redirected_to bank_path(assigns(:bank))
  end

  test "authorized users should not see bank" do
    get :show, id: @bank
    assert_redirected_to new_user_session_path
  end

  test "authorized users should be able to see bank" do
    @assert_block_via_login_and_get.call(:show, true)
  end

  test "unauthorized users should not get edit" do
    get :show, id: @bank
    assert_redirected_to new_user_session_path
  end

  test "authorized users should get edit" do
    @assert_block_via_login_and_get.call(:edit, true)
  end

  test "unauthorized users should not update bank" do
    @assert_block_via_login_and_patch.call('invalid')
  end

  test "authorized users should update bank" do
    @assert_block_via_login_and_patch.call('valid')
  end

=begin
  # destroy not configured

  test "unauthorized users should not destroy bank" do
    assert_no_difference 'Bank.count' do
      @destroy_action.call
    end
    assert_redirected_to new_user_session_path
  end

  test "authorized users should destroy bank" do
    sign_in @user
    assert_difference 'Bank.count', -1 do
      @destroy_action.call
    end
    assert_redirected_to banks_path
  end
=end

end
