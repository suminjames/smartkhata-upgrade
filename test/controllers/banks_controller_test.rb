require 'test_helper'

class BanksControllerTest < ActionController::TestCase
  setup do
    @bank = banks(:one)
  end

  test "unauthorized users should not get index" do
    get :index
    assert_response :redirect
  end

  test "should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:banks)
  end

  test "unauthorized users should not get new" do
    get :new
    assert_response :redirect
  end

  test "authorized users should get new" do
    sign_in users(:user)
    get :new
    assert_response :success
  end


  test "authorized users should create bank" do
    sign_in users(:user)
    assert_difference('Bank.count') do
      # post :create, bank: { address: @bank.address, bank_code: @bank.bank_code, contact_no: @bank.contact_no, name: @bank.name }
      post :create, bank: { address: @bank.address, bank_code: 'NCC', contact_no: @bank.contact_no, name: @bank.name }
    end

    assert_redirected_to bank_path(assigns(:bank))
  end

  test "for authorized users should show bank" do
    sign_in users(:user)
    get :show, id: @bank
    assert_response :success
  end

  test "authorized users should get edit" do
    sign_in users(:user)
    get :edit, id: @bank
    assert_response :success
  end

  test "authorized users should update bank" do
    sign_in users(:user)
    patch :update, id: @bank, bank: { address: @bank.address, bank_code: 'NIBL', contact_no: @bank.contact_no, name: @bank.name }
    assert_redirected_to bank_path(assigns(:bank))
  end

  test "authorized users should destroy bank" do
    sign_in users(:user)
    assert_difference('Bank.count', -1) do
      delete :destroy, id: @bank
    end

    assert_redirected_to banks_path
  end
end
