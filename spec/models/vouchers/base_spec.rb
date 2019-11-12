require 'rails_helper'

RSpec.describe Vouchers::Base do

  include_context 'session_setup'

  let(:client_account) { create(:client_account)}
  let(:ledger) { client_account.ledger }
  let(:purchase_bill) { create(:purchase_bill, client_account: client_account, net_amount: 3000) }
  let(:sales_bill) { create(:sales_bill, client_account: client_account, net_amount: 2000) }

  before do
    # user session needs to be set for doing any activity
    @assert_smartkhata_error = lambda { |voucher_base, client_account_id, bill_ids, clear_ledger|
      UserSession.set_console(nil, nil, nil)
      expect { voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, clear_ledger)} }.to raise_error(SmartKhataError)
    }
  end

  context ".set_bill_client" do
    it "should set bill client should return correct values for purchase bills" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 3000)
      bill_ids = [purchase_bill.id]
      client_account_id = client_account.id
      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, nil) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 1
      expect(amount.to_f).to eq 3000
      expect(settlement_by_clearance).to eq false
      expect(bill_ledger_adjustment).to eq 0
      expect(voucher_type).to eq 2
    end

    it "should return correct values for sales bills" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2000)
      bill_ids = [sales_bill.id]
      client_account_id = client_account.id
      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, nil) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 1
      expect(amount.to_f).to eq 2000
      expect(settlement_by_clearance).to eq false
      expect(bill_ledger_adjustment).to eq 0
      expect(voucher_type).to eq 1
    end

    it "should return correct values for sales bills less than purchase" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 1000)
      client_account_id = client_account.id
      bill_ids = [purchase_bill.id, sales_bill.id]
      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, nil) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 2
      expect(amount.to_f).to eq 1000
      expect(settlement_by_clearance).to eq false
      expect(bill_ledger_adjustment).to eq 0
      expect(voucher_type).to eq 2 #receipt
    end

    it "should return correct values for sales bills greater than purchase" do
      sales_bill = create(:sales_bill, client_account: client_account, net_amount: 4000)

      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -1000)
      client_account_id = client_account.id

      bill_ids = [purchase_bill.id, sales_bill.id]
      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)

      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, nil) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 2
      expect(amount.to_f).to eq 1000
      expect(settlement_by_clearance).to eq false
      expect(bill_ledger_adjustment).to eq 0
      expect(voucher_type).to eq 1 #payment
    end

    it "should return correct values for puchase bills with ledger balance less than bill amount" do
      # in this case the amount to receive from client should be 2000 not the bill amount of 3000 because client has some advance amount
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 2000)
      client_account_id = client_account.id
      bill_ids = [purchase_bill.id]

      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)

      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, nil) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 1
      expect(amount.to_f).to eq 3000.0
      expect(settlement_by_clearance).to eq false
      expect(bill_ledger_adjustment).to eq 0.0
      expect(voucher_type).to eq 2
    end

    it "should return correct values for sales bills with ledger balance greater than bill amount" do
      # in this case the amount to pay to client should be 1000 not the bill amount of 2000 because client has got some advance amount
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -1000)
      client_account_id = client_account.id

      bill_ids = [sales_bill.id]

      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)

      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, nil) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 1
      expect(amount.to_f).to eq 2000.0
      expect(settlement_by_clearance).to eq false
      expect(bill_ledger_adjustment).to eq 0.0
      expect(voucher_type).to eq 1
    end


    it "should return error for purchase bills with ledger balance less than zero" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2000)
      client_account_id = client_account.id

      bill_ids = [purchase_bill.id]

      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
      @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false)
    end

    it "should return error for sales bill with ledger balanc greater than zero" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2000)
      client_account_id = client_account.id

      bill_ids = [purchase_bill.id]

      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)
      @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false)
    end

    it "should return error when other bill ids are sent" do
      client_account_b = create(:client_account, name: 'subas')
      client_account_id = client_account.id
      bill_b = create(:purchase_bill, client_account: client_account_b, net_amount: 2000, balance_to_pay: 2000)
      bill_ids = [purchase_bill.id, bill_b.id]
      voucher_base = Vouchers::Base.new(bill_ids: bill_ids, client_account_id: client_account_id)

      @assert_smartkhata_error.call(voucher_base, client_account_id, bill_ids, false)
    end


    it "should return error when other client account id are nto sent for clear ledgers and bills" do
      bill_ids = [purchase_bill.id]
      expect { Vouchers::Base.new(bill_ids: bill_ids) }.to raise_error(SmartKhataError)
      expect { Vouchers::Base.new(clear_ledger: true) }.to raise_error(SmartKhataError)
    end

    it "should return receipt number for negative balance and clear ledger" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: -2500)
      client_account_id = client_account.id

      purchase_bill; sales_bill
      # bill_ids = [purchase_bill.id]

      voucher_base = Vouchers::Base.new(client_account_id: client_account_id, clear_ledger: true)

      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id,nil,nil,true) }



      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 2
      expect(amount.to_f).to eq 2500
      expect(settlement_by_clearance).to eq true
      expect(bill_ledger_adjustment).to eq -1500
      expect(voucher_type).to eq 1
    end

    it "should return receipt voucher for positive balance and clear ledger" do
      ledger_balance = create(:ledger_balance, ledger_id: ledger.id, opening_balance: nil, closing_balance: 2500)
      client_account_id = client_account.id

      # bill_ids = [purchase_bill.id]
      purchase_bill; sales_bill
      voucher_base = Vouchers::Base.new(client_account_id: client_account_id, clear_ledger: true)

      client_account_t,
          bills,
          amount,
          voucher_type,
          settlement_by_clearance,
          bill_ledger_adjustment = voucher_base.instance_eval{ set_bill_client(client_account_id,nil,nil,true) }

      expect(client_account_t.id).to eq client_account.id
      expect(bills.count).to eq 2
      expect(amount.to_f).to eq 2500
      expect(settlement_by_clearance).to eq true
      expect(bill_ledger_adjustment).to eq -1500
      expect(voucher_type).to eq 2

    end
  end
end
