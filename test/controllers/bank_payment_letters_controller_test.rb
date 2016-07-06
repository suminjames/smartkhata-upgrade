require 'test_helper'

class BankPaymentLettersControllerTest < ActionController::TestCase
  setup do
    @bank_payment_letter = bank_payment_letters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_payment_letters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bank_payment_letter" do
    assert_difference('BankPaymentLetter.count') do
      post :create, bank_payment_letter: { branch_id: @bank_payment_letter.branch_id, creator_id: @bank_payment_letter.creator_id, fy_code: @bank_payment_letter.fy_code, sales_settlement_id: @bank_payment_letter.sales_settlement_id, updater_id: @bank_payment_letter.updater_id, voucher_id: @bank_payment_letter.voucher_id }
    end

    assert_redirected_to bank_payment_letter_path(assigns(:bank_payment_letter))
  end

  test "should show bank_payment_letter" do
    get :show, id: @bank_payment_letter
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bank_payment_letter
    assert_response :success
  end

  test "should update bank_payment_letter" do
    patch :update, id: @bank_payment_letter, bank_payment_letter: { branch_id: @bank_payment_letter.branch_id, creator_id: @bank_payment_letter.creator_id, fy_code: @bank_payment_letter.fy_code, sales_settlement_id: @bank_payment_letter.sales_settlement_id, updater_id: @bank_payment_letter.updater_id, voucher_id: @bank_payment_letter.voucher_id }
    assert_redirected_to bank_payment_letter_path(assigns(:bank_payment_letter))
  end

  test "should destroy bank_payment_letter" do
    assert_difference('BankPaymentLetter.count', -1) do
      delete :destroy, id: @bank_payment_letter
    end

    assert_redirected_to bank_payment_letters_path
  end
end
