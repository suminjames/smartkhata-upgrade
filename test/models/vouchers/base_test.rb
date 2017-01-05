require 'test_helper'
class Vouchers::BaseTest < ActiveSupport::TestCase

  test "should raise error if object has bill_ids and not client_account" do
    assert_raise SmartKhataError do
      @voucher_base = Vouchers::Base.new(bill_ids: [1,2])
    end
  end

end