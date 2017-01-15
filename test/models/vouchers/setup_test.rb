require 'test_helper'
class Vouchers::SetupTest < ActiveSupport::TestCase
  attr_accessor :client_account, :ledger, :purchase_bill, :sales_bill

  def setup
    @client_account = create(:client_account)
    @ledger = client_account.ledger
    @purchase_bill = create(:purchase_bill, client_account: client_account, net_amount: 3000)
    @sales_bill = create(:sales_bill, client_account: client_account, net_amount: 2000)

    @assert_smartkhata_error = lambda { |voucher_base, client_account_id, bill_ids|
      assert_raise SmartKhataError do
        voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
      end
    }
  end

  class BasicVouchersTest < Vouchers::SetupTest
    test "should build  a journal voucher" do
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 0).voucher_and_relevant

      assert_equal "JVR", voucher.voucher_code
      assert_equal 1, voucher.particulars.size
    end

    test "should build a payment voucher" do
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 1).voucher_and_relevant

      assert_equal "PMT", voucher.voucher_code
      assert_equal 2, voucher.particulars.size
    end

    test "should build a receipt voucher" do
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 2).voucher_and_relevant

      assert_equal "RCV", voucher.voucher_code
      assert_equal 2, voucher.particulars.size
    end
  end

  class AdvancedVouchersClearLedgerTest < Vouchers::SetupTest
    test "should build a payment voucher when ledger balance is in cr" do
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: -3000 )
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 0, client_account_id: client_account.id, clear_ledger: true).voucher_and_relevant
      assert_equal "PMT", voucher.voucher_code
      assert_equal 2, voucher.particulars.size
    end

    test "should build a receipt voucher when ledger balance is in dr" do
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: 3000 )
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 0, client_account_id: client_account.id, clear_ledger: true).voucher_and_relevant
      assert_equal "RCV", voucher.voucher_code
      assert_equal 2, voucher.particulars.size
    end
  end

end