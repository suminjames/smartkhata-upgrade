require 'test_helper'
class ChequeEntries::VoidActivityTest < ActiveSupport::TestCase

  test "should return error if the  fycode is different than current" do
    @cheque_entry = cheque_entries(:one)
    UserSession.selected_fy_code = '7273'
    activity = ChequeEntries::VoidActivity.new(@cheque_entry)
    activity.process
    # exception = assert_raises(Exception) { ChequeEntries::VoidActivity.new(@cheque_entry).process }
    # assert_equal( "message", exception.message )
    assert_not_nil activity.error_message
    assert_equal 'Please select the current fiscal year', activity.error_message
  end

  test "should return cheque entry" do
    @cheque_entry = create(:cheque_entry)

    # @cheque_entry = cheque_entries(:one)
    # @particular = particulars(:three)

    # @cheq = cheque_entry_particular_associations(:one)
    # debugger
    assert_equal 2, @cheque_entry.particulars.size

    debugger
    # assert_equal 2, @cheque_entry.particulars_on_payment.size
    # assert_equal 0, @cheque_entry.particulars_on_receipt.size
    # modified_cheque_entry = ChequeEntries::VoidActivity.new(@cheque_entry).process
    # assert_kind_of ChequeEntry, modified_cheque_entry.cheque_entry

  end
end