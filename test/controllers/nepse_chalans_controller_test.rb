require 'test_helper'

class NepseChalansControllerTest < ActionController::TestCase
  include FiscalYearModule

  setup do
    sign_in users(:user)
    @nepse_chalan = nepse_chalans(:one)
    @bank_ledger = ledgers(:two)
    @share_transaction = share_transactions(:one)
    @block_assert = lambda{ |action|
      params = [:show, :edit].include?(action) ? {id: @nepse_chalan} : {}
      get action, params
      instance_var = action == :index ? :nepse_chalans : :nepse_chalan
      assert_response :success
      assert_template "nepse_chalans/#{action}"
      assert_not_nil assigns(instance_var)
    }
    set_fy_code_and_branch_from @nepse_chalan
  end

  test "should get index" do
    @block_assert.call(:index)
  end

  test "should get new" do
    @block_assert.call(:index)
  end

  test "should create nepse_chalan" do
    set_fy_code get_fy_code
    assert_difference('NepseChalan.count') do
      post :create, nepse_chalan: { deposited_date: @nepse_chalan.deposited_date, deposited_date_bs: @nepse_chalan.deposited_date_bs, voucher_id: @nepse_chalan.voucher_id}, bank_ledger_id: @bank_ledger.id, nepse_share_selection: [@share_transaction.id]
    end
    assert_not_nil flash[:notice]
    assert_redirected_to nepse_chalan_path(assigns(:nepse_chalan))
  end

  test "should show nepse_chalan" do
    @block_assert.call(:show)
  end

  test "should get edit" do
    @block_assert.call(:edit)
  end

  test "should update nepse_chalan" do
    patch :update, id: @nepse_chalan, nepse_chalan: { deposited_date: @nepse_chalan.deposited_date, deposited_date_bs: @nepse_chalan.deposited_date_bs, voucher_id: @nepse_chalan.voucher_id }
    assert_redirected_to nepse_chalan_path(assigns(:nepse_chalan))
  end

  test "should destroy nepse_chalan" do
    assert_difference('NepseChalan.count', -1) do
      delete :destroy, id: @nepse_chalan
    end

    assert_redirected_to nepse_chalans_path
  end
end
