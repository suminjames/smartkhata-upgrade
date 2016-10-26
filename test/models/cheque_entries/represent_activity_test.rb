require 'test_helper'
class ChequeEntries::RepresentActivityTest < ActiveSupport::TestCase
  test "should return error if the  fycode is different than current" do
    @cheque_entry = create(:cheque_entry)
    UserSession.selected_fy_code = '7273'
    activity = ChequeEntries::RepresentActivity.new(@cheque_entry, 'trishakti')
    activity.process
    assert_not_nil activity.error_message
    assert_equal 'Please select the current fiscal year', activity.error_message
  end

  test "should not bounce payment cheque" do
    @cheque_entry = create(:cheque_entry)
    activity = ChequeEntries::RepresentActivity.new(@cheque_entry, 'trishakti')
    activity.process
    assert_not_nil activity.error_message
    assert_equal 'The Cheque cant be represented.', activity.error_message
  end

  # voucher with two particulars ie external dr to bank cr
  test "should represent the cheque for voucher with single cheque entry and no bills" do
    @cheque_entry = create(:receipt_cheque_entry, status: :approved)
    @voucher = create(:voucher)
    @dr_particular = create(:debit_particular, voucher: @voucher)
    @cr_particular = create(:credit_particular, voucher: @voucher)

    @cheque_entry.particulars_on_payment << @dr_particular
    @cheque_entry.particulars_on_receipt << @cr_particular
    ChequeEntries::BounceActivity.new(@cheque_entry, 'trishakti').process
    @cheque_entry = ChequeEntry.find(@cheque_entry.id)


    activity = ChequeEntries::RepresentActivity.new(@cheque_entry, 'trishakti')
    activity.process

    assert_nil activity.error_message
    assert @cheque_entry.represented?
    # one for original another for bounce and the last for represent
    assert_equal 3, ChequeEntry.find(@cheque_entry.id).vouchers.uniq.size
    assert ChequeEntry.find(@cheque_entry.id).vouchers.uniq.last.complete?
  end
end