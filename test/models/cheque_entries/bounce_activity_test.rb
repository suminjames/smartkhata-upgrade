require 'test_helper'
class ChequeEntries::BounceActivityTest < ActiveSupport::TestCase
  include CustomDateModule

  def setup
    @bounce_date_bs = '2073-8-21'
    @cheque_date_ad = bs_to_ad(@bounce_date_bs) - 1
    @bounce_narration = 'This is a sample bounce narration.'
  end

  test "should return error if the  fycode is different than current" do
    skip("moved to rspec")
    @cheque_entry = create(:cheque_entry)
    UserSession.selected_fy_code = '7273'
    activity = ChequeEntries::BounceActivity.new(@cheque_entry, @bounce_date_bs, @bounce_narration, 'trishakti')
    activity.process
    assert_not_nil activity.error_message
    assert_equal 'Please select the current fiscal year', activity.error_message
  end

  test "should not bounce payment cheque" do
    skip("moved to rspec")

    @cheque_entry = create(:cheque_entry)
    activity = ChequeEntries::BounceActivity.new(@cheque_entry, @bounce_date_bs, @bounce_narration, 'trishakti')
    activity.process
    # assert_not_nil activity.error_message
    assert_equal 'The cheque can not be bounced.', activity.error_message
  end



  # this feature is not implemented yet
  test "should not bounces the cheque for voucher with multi cheque entry" do
    skip("moved to rspec")
    @cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 500, cheque_date: @cheque_date_ad)
    @cheque_entry_a = create(:receipt_cheque_entry, status: :approved, amount: 500)

    @voucher = create(:voucher)
    @dr_particular_a = create(:debit_particular, voucher: @voucher, amount: 500)
    @dr_particular_b = create(:debit_particular, voucher: @voucher, amount: 500)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 1000)


    @cheque_entry.particulars_on_payment << @dr_particular_a
    @cheque_entry.particulars_on_receipt << @cr_particular

    @cheque_entry_a.particulars_on_payment << @dr_particular_b
    @cheque_entry_a.particulars_on_receipt << @cr_particular


    activity = ChequeEntries::BounceActivity.new(@cheque_entry, @bounce_date_bs, @bounce_narration, 'trishakti')
    activity.process

    assert_equal "The cheque can not be bounced...Please contact technical support.", activity.error_message
    assert_not @cheque_entry.void?
    assert_not Voucher.find(@voucher.id).reversed?
  end

  test "should void the cheque for voucher with single cheque entry and bill with full amount" do
    skip("moved to rspec")
    @cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: @cheque_date_ad)
    @cheque_entry.cheque_date = @cheque_date_ad
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher, amount: 5000)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 5000)

    @client_account_a = create(:client_account, ledger: @dr_particular.ledger)
    @bill_a = create(:purchase_bill, client_account: @client_account_a, net_amount: 5000, balance_to_pay: 0)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular

    @voucher.bills_on_creation << @bill_a

    activity = ChequeEntries::BounceActivity.new(@cheque_entry, @bounce_date_bs, @bounce_narration, 'trishakti')
    activity.process

    @bill_a = Bill.find(@bill_a.id)
    assert_nil activity.error_message
    assert @bill_a.pending?
    assert_equal 5000, @bill_a.balance_to_pay
    assert @cheque_entry.bounced?
    assert Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end

  test "should void the cheque for voucher with single cheque entry and bill with partial amount" do
    skip("moved to rspec")
    @cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 4000, cheque_date: @cheque_date_ad)
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher, amount: 4000)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 4000)

    @client_account_a = create(:client_account, ledger: @dr_particular.ledger)
    @bill_a = create(:purchase_bill, client_account: @client_account_a, net_amount: 5000, balance_to_pay: 0)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular

    @voucher.bills_on_creation << @bill_a

    activity = ChequeEntries::BounceActivity.new(@cheque_entry, @bounce_date_bs, @bounce_narration, 'trishakti')
    activity.process

    @bill_a = Bill.find(@bill_a.id)
    assert_nil activity.error_message
    assert @bill_a.partial?
    assert_equal 4000, @bill_a.balance_to_pay
    assert @cheque_entry.bounced?
    assert Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end

  test "should void the cheque for voucher with single cheque entry and bills with full amount" do
    skip("moved to rspec")
    @cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: @cheque_date_ad)
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher, amount: 5000)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 5000)

    @client_account_a = create(:client_account, ledger: @dr_particular.ledger)
    @bill_a = create(:purchase_bill, client_account: @client_account_a, net_amount: 3000, balance_to_pay: 0)
    @bill_b = create(:purchase_bill, client_account: @client_account_a, net_amount: 2000, balance_to_pay: 0)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular

    @voucher.bills_on_creation << [ @bill_a, @bill_b]

    activity = ChequeEntries::BounceActivity.new(@cheque_entry, @bounce_date_bs, @bounce_narration, 'trishakti')
    activity.process

    @bill_a = Bill.find(@bill_a.id)
    @bill_b = Bill.find(@bill_b.id)

    assert_nil activity.error_message

    assert @bill_a.pending?
    assert_equal 3000, @bill_a.balance_to_pay
    assert @bill_b.pending?
    assert_equal 2000, @bill_b.balance_to_pay

    assert @cheque_entry.bounced?
    assert Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end
end