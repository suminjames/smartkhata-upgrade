require "#{Rails.root}/app/globalhelpers/custom_date_module"
require 'test_helper'

class BillTest < ActiveSupport::TestCase
  include CustomDateModule
  def setup
    share_transaction = ShareTransaction.selling.first
    bs_date = ad_to_bs(share_transaction.date.to_s)
    client_account = share_transaction.client_account
    @bill = Bill.new(date_bs: bs_date, provisional_base_price: '1000', client_account_id: client_account.id)
  end

  test "should be valid" do
    assert @bill.valid?
  end

  test "client_account_id should not be empty" do
    @bill.client_account_id = ' '
    assert @bill.invalid?
  end

  test "client_account_id should not be imaginary" do
    @bill.client_account_id = '3740237'
    assert @bill.invalid?
  end
end
