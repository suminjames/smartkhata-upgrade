require 'test_helper'
class Vouchers::CreateTest < ActiveSupport::TestCase
  attr_accessor :client_account, :ledger, :purchase_bill, :sales_bill, :dr_particular, :cr_particular, :voucher, :client_particular

  def setup
    @client_account = create(:client_account)
    @ledger = client_account.ledger
    @purchase_bill = create(:purchase_bill, client_account: client_account, net_amount: 3000)
    @sales_bill = create(:sales_bill, client_account: client_account, net_amount: 2000)
    @client_particular = build(:particular, ledger: @ledger, amount: 5000)

    @voucher = build(:voucher, voucher_type: 0)
    @dr_particular = build(:debit_particular, voucher: @voucher, amount: 5000)
    @cr_particular = build(:credit_particular, voucher: @voucher, amount: 5000)

    @assert_smartkhata_error = lambda { |voucher_base, client_account_id, bill_ids, clear_ledger|
      assert_raise SmartKhataError do
        voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, clear_ledger) }
      end
    }
  end

  # basic voucher with 2 particulars each
  class BasicVouchersTest < Vouchers::CreateTest
    test "should create a journal voucher" do
      voucher_type = 0
      voucher.particulars << dr_particular
      voucher.particulars << cr_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                           voucher: @voucher,
                           tenant_full_name: "Trishakti")
      assert voucher_creation.process
      assert_equal "JVR", voucher_creation.voucher.voucher_code
    end

    test "should create a payment voucher" do
      voucher_type = 1
      voucher.voucher_type = 1
      voucher.particulars << dr_particular
      voucher.particulars << cr_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      assert voucher_creation.process
      assert_equal "PVR", voucher_creation.voucher.voucher_code
    end

    test "should create a receipt voucher" do
      voucher_type = 2
      voucher.voucher_type = 2
      voucher.particulars << dr_particular
      voucher.particulars << cr_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      assert voucher_creation.process
      assert_equal "RCP", voucher_creation.voucher.voucher_code
    end
  end

  class AdvancedReceiptTest < Vouchers::CreateTest
    test "should settle purchase bill with full amount" do
      voucher.voucher_type = 2
      voucher_type = 2

      purchase_bill_id = purchase_bill.id
      client_particular.bills_selection = "#{purchase_bill_id}"
      client_particular.transaction_type = 1

      voucher.particulars << dr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "RCP", voucher_creation.voucher.voucher_code

      purchase_bill = Bill.find(purchase_bill_id)
      assert_equal 0, purchase_bill.balance_to_pay
      assert_equal "settled", purchase_bill.status
      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end

    test "should partially settle purchase bill with partial amount" do
      voucher.voucher_type = 2
      voucher_type = 2
      # make sure the client has dr balance equal to bill amount
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: 3000 )

      purchase_bill_id = purchase_bill.id
      client_particular.bills_selection = "#{purchase_bill_id}"
      client_particular.transaction_type = 1

      dr_particular.amount = 2000
      client_particular.amount = 2000

      voucher.particulars << dr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "RCP", voucher_creation.voucher.voucher_code

      purchase_bill = Bill.find(purchase_bill_id)
      assert_equal 1000, purchase_bill.balance_to_pay
      assert_equal "partial", purchase_bill.status
      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end

    test "should settle purchase bill with ledger having advance amount" do
      voucher.voucher_type = 2
      voucher_type = 2
      # make sure the client has dr balance less than bill amount
      # and the amount to be receive will be 2000
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: 2000 )

      purchase_bill_id = purchase_bill.id
      client_particular.bills_selection = "#{purchase_bill_id}"
      client_particular.transaction_type = 1

      # since bill has amount 3000, and account balance is 2000, remaining to be received is 1000ß
      dr_particular.amount = 2000
      client_particular.amount = 2000

      voucher.particulars << dr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "RCP", voucher_creation.voucher.voucher_code

      purchase_bill = Bill.find(purchase_bill_id)
      assert_equal 0, purchase_bill.balance_to_pay
      assert_equal "settled", purchase_bill.status
      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end
  end

  class AdvancedPaymentTest < Vouchers::CreateTest
    test "should settle sales bill with full amount" do
      voucher.voucher_type = 6
      voucher_type = 6

      # make sure the client has negative balance i.e in credit for payment
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: -3000 )

      sales_bill_id = sales_bill.id
      client_particular.bills_selection = "#{sales_bill_id}"


      voucher.particulars << cr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")

      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "PVR", voucher_creation.voucher.voucher_code

      sales_bill = Bill.find(sales_bill_id)
      assert_equal 0, sales_bill.balance_to_pay
      assert_equal "settled", sales_bill.status
      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end
    test "should partially settle sales bill with partial amount" do
      voucher.voucher_type = 6
      voucher_type = 6

      # make sure the client has dr balance equal to bill amount
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: -2000 )

      sales_bill_id = sales_bill.id
      client_particular.bills_selection = "#{sales_bill_id}"
      cr_particular.amount = 1000
      client_particular.amount = 1000

      voucher.particulars << cr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "PVR", voucher_creation.voucher.voucher_code

      sales_bill = Bill.find(sales_bill_id)
      assert_equal 1000, sales_bill.balance_to_pay
      assert_equal "partial", sales_bill.status
      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end

    test "should settle sales bill with ledger having advance amount" do
      voucher.voucher_type = 6
      voucher_type = 6
      # make sure the client has cr balance less than bill amount
      # and the amount to be paid will be 1000
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: -1000 )

      sales_bill_id = sales_bill.id
      client_particular.bills_selection = "#{sales_bill_id}"
      cr_particular.amount = 1000
      client_particular.amount = 1000

      voucher.particulars << cr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "PVR", voucher_creation.voucher.voucher_code

      sales_bill = Bill.find(sales_bill_id)
      assert_equal 0, sales_bill.balance_to_pay
      assert_equal "settled", sales_bill.status
      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end
  end

  class AdvancedBothPayReceiveTest < Vouchers::CreateTest
    test "should settle both type of bills" do
      voucher.voucher_type = 2
      voucher_type = 2
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: 1000 )

      purchase_bill_id = purchase_bill.id
      sales_bill_id = sales_bill.id

      client_particular.bills_selection = "#{purchase_bill_id},#{sales_bill_id}"
      client_particular.transaction_type = 1
      client_particular.amount = 1000
      dr_particular.amount = 1000

      voucher.particulars << dr_particular
      voucher.particulars << client_particular



      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: @voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti")
      voucher_creation.process
      assert_nil voucher_creation.error_message
      assert_equal "RCP", voucher_creation.voucher.voucher_code

      sales_bill = Bill.find(sales_bill_id)
      assert_equal 0, sales_bill.balance_to_pay
      assert_equal "settled", sales_bill.status

      purchase_bill = Bill.find(purchase_bill_id)
      assert_equal 0, purchase_bill.balance_to_pay
      assert_equal "settled", purchase_bill.status



      assert_equal 1, voucher_creation.settlements.size
      refute voucher_creation.voucher.is_payment_bank?
    end
  end
end
