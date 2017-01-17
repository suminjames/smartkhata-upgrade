require 'test_helper'

class BankPaymentLettersControllerTest < ActionController::TestCase
  include FiscalYearModule
  setup do
    sign_in users(:user)
    @request.host = 'trishakti.lvh.me'
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

=begin
  # unable to create a bank payment letter
  test "should create bank_payment_letter" do
    # need a bill with current fy code
    original_controller = @controller
    @controller = BillsController.new
    fy_code = get_fy_code

    assert_difference 'Bill.count' do
      post :create, bill: { date_bs: fiscal_year_last_day(fy_code), provisional_base_price: '100000', client_account_id: client_accounts(:one), fy_code: fy_code, branch_id: 1 }
    end
    bill = assigns(:bill)
    @controller = original_controller

    set_fy_code_and_branch_from bill
    assert_difference('BankPaymentLetter.count') do
      post :create, bank_payment_letter: { branch_id: @bank_payment_letter.branch_id, creator_id: @bank_payment_letter.creator_id, fy_code: @bank_payment_letter.fy_code, nepse_settlement_id: @bank_payment_letter.nepse_settlement_id, updater_id: @bank_payment_letter.updater_id, voucher_id: @bank_payment_letter.voucher_id },
                    bill_ids: [bill.id.to_s]
    end
    assert_redirected_to bank_payment_letter_path(assigns(:bank_payment_letter))
  end
=end

  test "should show bank_payment_letter" do
    get :show, id: @bank_payment_letter
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bank_payment_letter
    assert_response :success
  end

  test "should update bank_payment_letter" do
    patch :update, id: @bank_payment_letter, bank_payment_letter: { branch_id: @bank_payment_letter.branch_id, creator_id: @bank_payment_letter.creator_id, fy_code: @bank_payment_letter.fy_code, nepse_settlement_id: @bank_payment_letter.nepse_settlement_id, updater_id: @bank_payment_letter.updater_id, voucher_id: @bank_payment_letter.voucher_id }
    assert_redirected_to bank_payment_letter_path(assigns(:bank_payment_letter))
  end

  test "should destroy bank_payment_letter" do
    assert_difference('BankPaymentLetter.count', -1) do
      delete :destroy, id: @bank_payment_letter
    end

    assert_redirected_to bank_payment_letters_path
  end
end
