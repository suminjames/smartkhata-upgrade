require 'test_helper'
class ChequeEntries::VoidActivityTest < ActiveSupport::TestCase

  test "should return error if the  fycode is different than current" do
    @cheque_entry = cheque_entries(:one)
    UserSession.selected_fy_code = '7273'
    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')
    activity.process
    assert_not_nil activity.error_message
    assert_equal 'Please select the current fiscal year', activity.error_message
  end

  test "should not void receipt cheque" do
    @cheque_entry = create(:receipt_cheque_entry)
    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')
    activity.process
    assert_not_nil activity.error_message
    assert_equal 'The Cheque cant be made Void.', activity.error_message
  end

  # voucher with two particulars ie bank cr to other dr
  test "should void the cheque for voucher with single cheque entry and no bills" do

    @cheque_entry = create(:cheque_entry, status: :approved)
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher)
    @cr_particular = create(:credit_particular, voucher: @voucher)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular
    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')

    activity.process
    assert_nil activity.error_message
    assert @cheque_entry.void?
    assert Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end

  test "should void the cheque for voucher with multi cheque entry and no bills" do

    @cheque_entry = create(:cheque_entry, status: :approved)
    @cheque_entry_a = create(:cheque_entry, status: :approved)

    @voucher = create(:voucher)
    @dr_particular_a = create(:debit_particular, voucher: @voucher, amount: 500)
    @dr_particular_b = create(:debit_particular, voucher: @voucher, amount: 500)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 1000)


    @cheque_entry.particulars_on_payment << @dr_particular_a
    @cheque_entry.particulars_on_receipt << @cr_particular

    @cheque_entry_a.particulars_on_payment << @dr_particular_b
    @cheque_entry_a.particulars_on_receipt << @cr_particular


    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')
    activity.process

    assert_nil activity.error_message
    assert @cheque_entry.void?
    assert_not Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end

  test "should void the cheque for voucher with single cheque entry and bill with full amount" do

    @cheque_entry = create(:cheque_entry, status: :approved, amount: 5000)
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher, amount: 5000)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 5000)

    @client_account_a = create(:client_account, ledger: @dr_particular.ledger)
    @bill_a = create(:sales_bill, client_account: @client_account_a, net_amount: 5000, balance_to_pay: 0)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular

    @voucher.bills_on_creation << @bill_a

    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')
    activity.process

    @bill_a = Bill.find(@bill_a.id)
    assert_nil activity.error_message
    assert @bill_a.pending?
    assert_equal 5000, @bill_a.balance_to_pay
    assert @cheque_entry.void?
    assert Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end

  test "should void the cheque for voucher with single cheque entry and bill with partial amount" do

    @cheque_entry = create(:cheque_entry, status: :approved, amount: 5000)
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher, amount: 5000)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 5000)

    @client_account_a = create(:client_account, ledger: @dr_particular.ledger)
    @bill_a = create(:sales_bill, client_account: @client_account_a, net_amount: 6000, balance_to_pay: 0)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular

    @voucher.bills_on_creation << @bill_a

    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')
    activity.process

    @bill_a = Bill.find(@bill_a.id)
    assert @bill_a.partial?
    assert_equal 5000, @bill_a.balance_to_pay
    assert_nil activity.error_message
    assert @cheque_entry.void?
    assert Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end
  #
  test "should void the cheque for voucher with multi cheque entry and bills" do

    @cheque_entry = create(:cheque_entry, status: :approved, amount: 5000)
    @cheque_entry_a = create(:cheque_entry, status: :approved, amount: 4000)

    @voucher = create(:voucher)
    @dr_particular_a = create(:debit_particular, voucher: @voucher, amount: 500)
    @dr_particular_b = create(:debit_particular, voucher: @voucher, amount: 500)
    @cr_particular = create(:credit_particular, voucher: @voucher, amount: 1000)

    @client_account_a = create(:client_account, ledger: @dr_particular_a.ledger)
    @bill_a = create(:sales_bill, client_account: @client_account_a, net_amount: 6000, balance_to_pay: 0)
    @client_account_b = create(:client_account, ledger: @dr_particular_b.ledger)
    @bill_b = create(:sales_bill, client_account: @client_account_b, net_amount: 4000, balance_to_pay: 0)

    @cheque_entry.particulars_on_payment << @dr_particular_a
    @cheque_entry.particulars_on_receipt << @cr_particular

    @cheque_entry_a.particulars_on_payment << @dr_particular_b
    @cheque_entry_a.particulars_on_receipt << @cr_particular

    @voucher.bills_on_creation << [@bill_a, @bill_b]


    activity = ChequeEntries::VoidActivity.new(@cheque_entry, 'trishakti')
    activity.process

    @bill_a = Bill.find(@bill_a.id)
    @bill_b = Bill.find(@bill_b.id)

    assert_nil activity.error_message
    assert @cheque_entry.void?
    assert @bill_a.partial?
    assert_equal 5000, @bill_a.balance_to_pay
    assert @bill_b.settled?
    assert_equal 0, @bill_b.balance_to_pay

    assert_not Voucher.find(@voucher.id).reversed?
    assert_equal 2, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
  end


end