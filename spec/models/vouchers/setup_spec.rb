require 'rails_helper'

RSpec.describe Vouchers::Setup do

  include_context 'session_setup'

  let(:client_account) { create(:client_account)}
  let(:ledger) { client_account.ledger }
  let(:purchase_bill) { create(:purchase_bill, client_account: client_account, net_amount: 3000) }
  let(:sales_bill) { create(:sales_bill, client_account: client_account, net_amount: 2000) }

  describe "basic vouchers" do
    it "should build  a journal voucher" do
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 0).voucher_and_relevant(1, 7374)

      expect(voucher.voucher_code).to eq("JVR")
      expect(voucher.particulars.size).to eq(1)
    end

    it "should build a payment voucher" do
      voucher,
        is_payment_receipt,
        ledger_list_financial,
        ledger_list_available,
        default_ledger_id,
        voucher_type,
        vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 1).voucher_and_relevant(1, 7374)
      expect(voucher.voucher_code).to eq("PMT")
      expect(voucher.particulars.size).to eq(2)
    end

    it "should build a receipt voucher" do
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 2).voucher_and_relevant(1, 7374)

      expect(voucher.voucher_code).to eq("RCV")
      expect(voucher.particulars.size).to eq(2)
    end
  end

  describe "clear ledgers advanced vouchers" do
    it "should build a payment voucher when ledger balance is in cr" do
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: -3000 )
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 0, client_account_id: client_account.id, clear_ledger: true).voucher_and_relevant(1, 7374)
      expect(voucher.voucher_code).to eq("PMT")
      expect(voucher.particulars.size).to eq(2)
    end

    it "should build a receipt voucher when ledger balance is in dr" do
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: 3000 )
      voucher,
          is_payment_receipt,
          ledger_list_financial,
          ledger_list_available,
          default_ledger_id,
          voucher_type,
          vendor_account_list,
          client_ledger_list = Vouchers::Setup.new(voucher_type: 0, client_account_id: client_account.id, clear_ledger: true).voucher_and_relevant(1, 7374)
      expect(voucher.voucher_code).to eq("PMT")
      expect(voucher.particulars.size).to eq(2)
    end
  end
end
