# require 'test_helper'
# class Vouchers::BaseTest < ActiveSupport::TestCase
#   attr_accessor :client_account, :ledger, :purchase_bill, :sales_bill
#
#   def setup
#     @client_account = create(:client_account)
#     @ledger = client_account.ledger
#     @purchase_bill = create(:purchase_bill, client_account: client_account, net_amount: 3000)
#     @sales_bill = create(:sales_bill, client_account: client_account, net_amount: 2000)
#
#     @assert_smartkhata_error = lambda { |voucher_base, client_account_id, bill_ids, clear_ledger|
#       assert_raise SmartKhataError do
#         voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, clear_ledger) }
#       end
#     }
#   end
#   test "set bill client should return correct values for purchase bills" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 3000)
#     client_account_id = client_account.id
#     bill_ids = [purchase_bill.id]
#
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal bills.count, 1
#     assert_equal 3000, amount.to_f
#     assert_equal false,settlement_by_clearance
#     assert_equal 0,bill_ledger_adjustment
#     assert_equal 2, voucher_type
#   end
#   test "set bill client should return correct values for sales bills" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2000)
#     client_account_id = client_account.id
#
#     bill_ids = [sales_bill.id]
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal bills.count, 1
#     assert_equal 2000, amount.to_f
#     assert_equal false,settlement_by_clearance
#     assert_equal 0,bill_ledger_adjustment
#     assert_equal 1, voucher_type
#   end
#
#   test "set bill client should return correct values for sales bills less than purchase" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 1000)
#     client_account_id = client_account.id
#
#     bill_ids = [purchase_bill.id, sales_bill.id]
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal bills.count, 2
#     assert_equal 1000, amount.to_f
#     assert_equal false,settlement_by_clearance
#     assert_equal 0,bill_ledger_adjustment
#     assert_equal 2, voucher_type #voucher type is receipt
#   end
#   test "set bill client should return correct values for sales bills greater than purchase" do
#     skip("moved to rspec")
#     sales_bill = create(:sales_bill, client_account: client_account, net_amount: 4000)
#
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -1000)
#     client_account_id = client_account.id
#
#     bill_ids = [purchase_bill.id, sales_bill.id]
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal bills.count, 2
#     assert_equal 1000, amount.to_f
#     assert_equal false,settlement_by_clearance
#     assert_equal 0,bill_ledger_adjustment
#     assert_equal 1, voucher_type
#   end
#
#   test "setting up bills and amount should return correct values for purchase bills with ledger balance less than bill amount" do
#     skip("moved to rspec")
#     # in this case the amount to receive from client should be 2000 not the bill amount of 3000 because client has some advance amount
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 2000)
#     client_account_id = client_account.id
#
#     bill_ids = [purchase_bill.id]
#
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal bills.count, 1
#     assert_equal 2000, amount.to_f
#     assert_equal false,settlement_by_clearance
#     assert_equal 1000,bill_ledger_adjustment
#     assert_equal 2, voucher_type
#   end
#
#   test "setting up bills and amount should return correct values for sales bills with ledger balance greater than bill amount" do
#     skip("moved to rspec")
#     # in this case the amount to pay to client should be 1000 not the bill amount of 2000 because client has got some advance amount
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -1000)
#     client_account_id = client_account.id
#
#     bill_ids = [sales_bill.id]
#
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal bills.count, 1
#     assert_equal 1000, amount.to_f
#     assert_equal false,settlement_by_clearance
#     assert_equal 1000,bill_ledger_adjustment
#     assert_equal 1, voucher_type
#   end
#
#   test "setting up bills and amount should return error for purchase bills with ledger balance less than zero" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2000)
#     client_account_id = client_account.id
#
#     bill_ids = [purchase_bill.id]
#
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#     @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false)
#   end
#
#   test "setting up bills and amount should return error for sales bills with ledger balance greater than zero" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2000)
#     client_account_id = client_account.id
#
#     bill_ids = [purchase_bill.id]
#
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#     @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false)
#   end
#
#   test "set bill client should return error when other bill ids are sent" do
#     skip("moved to rspec")
#     client_account_b = create(:client_account, name: 'subas')
#     client_account_id = client_account.id
#     bill_b = create(:purchase_bill, client_account: client_account_b, net_amount: 2000, balance_to_pay: 2000)
#     bill_ids = [purchase_bill.id, bill_b.id]
#     voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
#
#     @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false)
#   end
#
#   test "set bill client should return error when other client account id  are  not sent for clear ledger & bills " do
#     skip("moved to rspec")
#     bill_ids = [purchase_bill.id]
#     assert_raise SmartKhataError do
#       Vouchers::Base.new(bill_ids: bill_ids)
#     end
#     assert_raise SmartKhataError do
#       Vouchers::Base.new(clear_ledger: true)
#     end
#   end
# #   clear ledger section
#   test "negative balance and clear ledger should give receipt voucher" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2500)
#     client_account_id = client_account.id
#
#     # bill_ids = [purchase_bill.id]
#     voucher_base = Vouchers::Base.new(client_account_id: client_account_id, clear_ledger: true)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, nil,true) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal 2, bills.count
#     assert_equal 2500, amount.to_f
#     assert_equal true,settlement_by_clearance
#     assert_equal -1500, bill_ledger_adjustment.to_f
#     assert_equal 1, voucher_type
#   end
#
#   test "positive balance and clear ledger should give receipt voucher" do
#     skip("moved to rspec")
#     ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 2500)
#     client_account_id = client_account.id
#
#     # bill_ids = [purchase_bill.id]
#
#     voucher_base = Vouchers::Base.new(client_account_id: client_account_id, clear_ledger: true)
#
#     client_account_t,
#         bills,
#         amount,
#         voucher_type,
#         settlement_by_clearance,
#         bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, nil,true) }
#
#     assert_equal client_account_t.id, client_account.id
#     assert_equal 2, bills.count
#     assert_equal 2500, amount.to_f
#     assert_equal true,settlement_by_clearance
#     assert_equal -1500, bill_ledger_adjustment.to_f
#     assert_equal 2, voucher_type
#   end
# end