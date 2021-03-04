require 'rails_helper'

RSpec.describe Vouchers::Create do

  include_context 'session_setup'
  include ActiveSupport::Testing::TimeHelpers
  include FiscalYearModule
  let(:current_user){@user}

  let(:client_account) { create(:client_account)}
  let(:ledger) { client_account.ledger }
  let(:another_ledger){ create(:ledger) }
  let(:purchase_bill) { create(:purchase_bill, client_account: client_account, net_amount: 3000) }
  let(:sales_bill) { create(:sales_bill, client_account: client_account, net_amount: 2000) }
  let(:client_particular) {build(:particular, ledger: another_ledger, amount: 5000)}
  let(:voucher) { build(:voucher, voucher_type: 0, value_date_bs: '2073-09-24') }
  let(:dr_particular) { build(:debit_particular, voucher: voucher, amount: 5000, ledger: another_ledger, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days) }
  let(:cr_particular) { build(:credit_particular, voucher: voucher, amount: 5000, ledger: another_ledger, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days) }

  before do
    travel_to "2017-01-01".to_date
    # user session needs to be set for doing any activity
    @assert_smartkhata_error = lambda { |voucher_base, client_account_id, bill_ids, clear_ledger|
      expect { voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids, clear_ledger)} }.to raise_error(SmartKhataError)
    }
    create( :ledger, name: "Cash")
  end
  describe "vouchers" do
    context "when journal voucher" do
      context "when particular description is not present" do
        let(:voucher) {create(:voucher, voucher_type: 0, desc: "voucher narration", date: Date.today, value_date_bs: '2073-09-24')}
        let(:d_particular) {create(:particular, amount: 1000, transaction_type: 0, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        let(:c_particular) {create(:particular, amount: 1000, transaction_type: 1, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        it "should display voucher narration" do
          voucher.particulars << d_particular
          voucher.particulars << c_particular
          voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                  voucher: voucher,
                                                  tenant_full_name: "Trishakti",
                                                  current_user: User.first,
                                                  selected_fy_code: get_fy_code,
                                                  selected_branch_id: Branch.first.id,
                                                  )
          
          expect(voucher_creation.process).to be_truthy
          
          expect(voucher_creation.voucher.particulars.first.description).to eq("voucher narration")
          expect(voucher_creation.voucher.particulars.last.description).to eq("voucher narration")
        end
      end

      context "when particular description is  present" do
        let(:voucher) {create(:voucher, voucher_type: 0, desc: "voucher narration", value_date_bs: '2073-09-24')}
        let(:d_particular) {create(:particular, amount: 1000, transaction_type: 0, description: "description for dr particular", value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        let(:c_particular) {create(:particular, amount: 1000, transaction_type: 1, description: "description for cr particular", value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        it "should display particular description" do
          voucher.particulars << d_particular
          voucher.particulars << c_particular
          voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                  voucher: voucher,
                                                  tenant_full_name: "Trishakti",
                                                  current_user: User.first,
                                                  selected_fy_code: get_fy_code,
                                                  selected_branch_id: Branch.first.id)
          expect(voucher_creation.process).to be_truthy
          expect(voucher_creation.voucher.particulars.pluck :description).to match_array(["description for dr particular", 'description for cr particular'])
          # expect(voucher_creation.voucher.particulars.first.description).to eq("description for dr particular")
          # expect(voucher_creation.voucher.particulars.last.description).to eq("description for cr particular")
        end
      end
    end

    context "when payment voucher" do
      context "when particular description is not present" do
        let(:voucher) {create(:voucher, voucher_type: 1, desc: "voucher narration", value_date_bs: '2073-09-24')}
        let(:d_particular) {create(:particular, amount: 1000, transaction_type: 0, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        let(:c_particular) {create(:particular, amount: 1000, transaction_type: 1, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        it "should display voucher narration" do
          voucher.particulars << d_particular
          voucher.particulars << c_particular
          voucher_creation = Vouchers::Create.new(voucher_type: 1,
                                                  voucher: voucher,
                                                  voucher_settlement_type: "default",
                                                  tenant_full_name: "Trishakti",
                                                  current_user: User.first,
                                                  selected_fy_code: get_fy_code,
                                                  selected_branch_id: Branch.first.id)
          expect(voucher_creation.process).to be_truthy
          expect(voucher_creation.voucher.particulars.first.description).to eq("voucher narration")
          expect(voucher_creation.voucher.particulars.last.description).to eq("voucher narration")
        end
      end

      context "when particular description is  present" do
        let(:voucher) {create(:voucher, voucher_type: 1, desc: "voucher narration", value_date_bs: '2073-09-24')}
        let(:d_particular) {create(:particular, amount: 1000, transaction_type: 0, description: "description for dr particular", value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        let(:c_particular) {create(:particular, amount: 1000, transaction_type: 1, description: "description for cr particular", value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        it "should display particular description" do
          voucher.particulars << d_particular
          voucher.particulars << c_particular
          voucher_creation = Vouchers::Create.new(voucher_type: 1,
                                                  voucher: voucher,
                                                  voucher_settlement_type: "default",
                                                  tenant_full_name: "Trishakti",
                                                  current_user: User.first,
                                                  selected_fy_code: get_fy_code,
                                                  selected_branch_id: Branch.first.id)
          expect(voucher_creation.process).to be_truthy
          expect(voucher_creation.voucher.particulars.pluck :description).to match_array(
                          ["description for dr particular", 'description for cr particular'])
        end
      end
    end

    context "when receipt voucher" do
      context "when particular description is not present" do
        let(:voucher) {create(:voucher, voucher_type: 2, desc: "voucher narration", value_date_bs: '2073-09-24')}
        let(:d_particular) {create(:particular, amount: 1000, transaction_type: 0, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        let(:c_particular) {create(:particular, amount: 1000, transaction_type: 1, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        it "should display voucher narration" do
          voucher.particulars << d_particular
          voucher.particulars << c_particular
          voucher_creation = Vouchers::Create.new(voucher_type: 2,
                                                  voucher: voucher,
                                                  voucher_settlement_type: "default",
                                                  tenant_full_name: "Trishakti",
                                                  current_user: User.first,
                                                  selected_fy_code: get_fy_code,
                                                  selected_branch_id: Branch.first.id)
          expect(voucher_creation.process).to be_truthy
          expect(voucher_creation.voucher.particulars.first.description).to eq("voucher narration")
          expect(voucher_creation.voucher.particulars.last.description).to eq("voucher narration")
        end
      end

      context "when particular description is  present" do
        let(:voucher) {create(:voucher, voucher_type: 2, desc: "voucher narration", value_date_bs: '2073-09-24')}
        let(:d_particular) {create(:particular, amount: 1000, transaction_type: 0, description: "description for dr particular", value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        let(:c_particular) {create(:particular, amount: 1000, transaction_type: 1, description: "description for cr particular", value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
        it "should display particular description" do
          voucher.particulars << d_particular
          voucher.particulars << c_particular
          voucher_creation = Vouchers::Create.new(voucher_type: 2,
                                                  voucher: voucher,
                                                  voucher_settlement_type: "default",
                                                  tenant_full_name: "Trishakti",
                                                  current_user: User.first,
                                                  selected_fy_code: get_fy_code,
                                                  selected_branch_id: Branch.first.id)
          expect(voucher_creation.process).to be_truthy
          expect(voucher_creation.voucher.particulars.pluck :description).to match_array(
                ["description for dr particular", 'description for cr particular'])

        end
      end
    end
  end

  describe "basic vouchers" do
    it "should create a journal voucher" do
      voucher.particulars << dr_particular
      voucher.particulars << cr_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher.voucher_type,
                                              voucher: voucher,
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: Branch.first.id)

      expect(voucher_creation.process).to be_truthy
      expect(voucher_creation.voucher.voucher_code).to eq("JVR")
    end

    it "should create a payment voucher" do
      voucher_type = 1
      voucher.voucher_type = 1
      voucher.particulars << dr_particular
      voucher.particulars << cr_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: Branch.first.id)
      expect(voucher_creation.process).to be_truthy
      expect(voucher_creation.voucher.voucher_code).to eq("PMT")
    end

    it "should create a receipt voucher" do
      voucher_type = 2
      voucher.voucher_type = 2
      voucher.particulars << dr_particular
      voucher.particulars << cr_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)
      expect(voucher_creation.process).to be_truthy
      expect(voucher_creation.voucher.voucher_code).to eq("RCV")
    end
  end

  describe "duplicate cheque entry" do
    it "should not create receipt voucher with duplicate cheque entry" do
      voucher_type = 2
      bank_ledger = create(:bank_ledger)
      client_ledger = ledger
      voucher_params = {"date_bs"=>"2073-10-21", "desc"=>"", "particulars_attributes"=>{"0"=>{"ledger_id"=>bank_ledger.id, "amount"=>"12", "transaction_type"=>"dr", "cheque_number"=>"234234", "additional_bank_id"=>"1", "branch_id"=>"1"}, "3"=>{"ledger_id"=>client_ledger.id, "amount"=>"12", "transaction_type"=>"cr", "branch_id"=>"1", "bills_selection"=>"", "selected_bill_names"=>""}}}

      voucher_1 = Voucher.new(voucher_params)
      voucher_creation_1 = Vouchers::Create.new(
          voucher_type: voucher_type,
          voucher: voucher_1,
          voucher_settlement_type: "default",
          tenant_full_name: "Trishakti",
          current_user: User.first,
          selected_fy_code: get_fy_code,
          selected_branch_id: 1
      )
      expect(voucher_creation_1.process).to be_truthy
      expect(voucher_creation_1.voucher.voucher_code).to eq("RCB")

      voucher_2 = Voucher.new(voucher_params)
      voucher_creation_2 = Vouchers::Create.new(
          voucher_type: voucher_type,
          voucher: voucher_2,
          voucher_settlement_type: "default",
          tenant_full_name: "Trishakti",
          current_user: User.first,
          selected_fy_code: get_fy_code,
          selected_branch_id: 1
      )
      expect(voucher_creation_2.process).to_not be_truthy
      expect(voucher_creation_2.error_message).to eq("Cheque number is already taken. If reusing the cheque is really necessary, it must be bounced first.")
    end

    it "should create receipt voucher for bounced cheque entry" do
      voucher_type = 2
      bank_ledger = create(:bank_ledger)
      client_ledger = ledger
      voucher_params = {"date_bs"=>"2073-10-21", "desc"=>"", "particulars_attributes"=>{"0"=>{"ledger_id"=>bank_ledger.id, "amount"=>"12", "transaction_type"=>"dr", "cheque_number"=>"234234", "additional_bank_id"=>"1", "branch_id"=>"1"}, "3"=>{"ledger_id"=>client_ledger.id, "amount"=>"12", "transaction_type"=>"cr", "branch_id"=>"1", "bills_selection"=>"", "selected_bill_names"=>""}}}

      voucher_1 = Voucher.new(voucher_params)
      voucher_creation_1 = Vouchers::Create.new(
          voucher_type: voucher_type,
          voucher: voucher_1,
          voucher_settlement_type: "default",
          tenant_full_name: "Trishakti",
          current_user: User.first,
          selected_fy_code: get_fy_code,
          selected_branch_id: 1
      )
      
      expect(voucher_creation_1.process).to be_truthy
      expect(voucher_creation_1.voucher.voucher_code).to eq("RCB")

      returned_voucher = voucher_creation_1.voucher
      cheque_entry = returned_voucher.cheque_entries.uniq.first
      cheque_entry.bounced!

      voucher_2 = Voucher.new(voucher_params)
      voucher_creation_2 = Vouchers::Create.new(
          voucher_type: voucher_type,
          voucher: voucher_2,
          voucher_settlement_type: "default",
          tenant_full_name: "Trishakti",
          current_user: User.first,
          selected_fy_code: get_fy_code,
          selected_branch_id: 1
      )
      expect(voucher_creation_2.process).to be_truthy
      expect(voucher_creation_2.error_message).to be_nil
    end
  end

  describe "complex receipt vouchers" do
    it "should settle purchase bill with full amount" do
      voucher.voucher_type = 2
      voucher_type = 2

      purchase_bill_id = purchase_bill.id
      client_particular.bills_selection = "#{purchase_bill_id}"
      client_particular.transaction_type = 1

      voucher.particulars << dr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)
      voucher_creation.process

      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("RCP")

      purchase_bill = Bill.find(purchase_bill_id)

      expect(purchase_bill.balance_to_pay).to eq(0)
      expect(purchase_bill.status).to eq("settled")
      expect(voucher_creation.settlements.size).to eq 1
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy

    end

    it "should partially settle purchase bill with partial amount" do
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
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)
      voucher_creation.process
      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("RCP")

      purchase_bill = Bill.find(purchase_bill_id)
      expect(purchase_bill.balance_to_pay).to eq(1000)
      expect(purchase_bill.status).to eq("partial")
      expect(voucher_creation.settlements.size).to eq 1
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy
    end

    it "should settle purchase bill with ledger having advance amount" do
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
      # the adjustment amount in particular
      client_particular.ledger_balance_adjustment = 1000

      voucher.particulars << dr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)
      voucher_creation.process
      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("RCP")

      purchase_bill = Bill.find(purchase_bill_id)
      expect(purchase_bill.balance_to_pay).to eq(0)
      expect(purchase_bill.status).to eq("settled")
      expect(voucher_creation.settlements.size).to eq 1
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy
    end
  end

  describe "complex payment" do
    it "should settle sales bill with full amount" do
      voucher.voucher_type = 6
      voucher_type = 6

      # make sure the client has negative balance i.e in credit for payment
      create(:ledger_balance, ledger: ledger, opening_balance: -3000 )

      sales_bill_id = sales_bill.id
      client_particular.bills_selection = "#{sales_bill_id}"


      voucher.particulars << cr_particular
      voucher.particulars << client_particular
      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)

      voucher_creation.process
      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("PVR")

      sales_bill = Bill.find(sales_bill_id)
      expect(sales_bill.balance_to_pay).to eq(0)
      expect(sales_bill.status).to eq("settled")
      expect(voucher_creation.settlements.size).to eq 1
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy
    end

    it "should partially settle sales bill with partial amount" do
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
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)
      voucher_creation.process
      sales_bill = Bill.find(sales_bill_id)

      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("PVR")
      expect(sales_bill.balance_to_pay).to eq(1000)
      expect(sales_bill.status).to eq("partial")
      expect(voucher_creation.settlements.size).to eq 1
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy
    end

    it "should settle sales bill with ledger having advance amount" do
      voucher.voucher_type = 6
      voucher_type = 6
      # make sure the client has cr balance less than bill amount
      # and the amount to be paid will be 1000
      ledger_balance = create(:ledger_balance, ledger: ledger, opening_balance: -1000 )

      sales_bill_id = sales_bill.id
      client_particular.bills_selection = "#{sales_bill_id}"
      cr_particular.amount = 1000
      client_particular.amount = 1000
      client_particular.ledger_balance_adjustment = 1000
      voucher.particulars << cr_particular
      voucher.particulars << client_particular

      voucher_creation = Vouchers::Create.new(voucher_type: voucher_type,
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)

      voucher_creation.process
      sales_bill = Bill.find(sales_bill_id)

      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("PVR")
      expect(sales_bill.balance_to_pay).to eq(0)
      expect(sales_bill.status).to eq("settled")
      expect(voucher_creation.settlements.size).to eq 1
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy
    end
  end

  describe "complex payment and receipt" do
    it "should settle both type of bills" do
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
                                              voucher: voucher,
                                              voucher_settlement_type: "default",
                                              tenant_full_name: "Trishakti",
                                              current_user: User.first,
                                              selected_fy_code: get_fy_code,
                                              selected_branch_id: 1)
      voucher_creation.process

      expect(voucher_creation.error_message).to be_nil
      expect(voucher_creation.voucher.voucher_code).to eq("RCP")

      sales_bill = Bill.find(sales_bill_id)
      expect(sales_bill.balance_to_pay).to eq(0)
      expect(sales_bill.status).to eq("settled")

      purchase_bill = Bill.find(purchase_bill_id)
      expect(purchase_bill.balance_to_pay).to eq(0)
      expect(purchase_bill.status).to eq("settled")

      expect(voucher_creation.settlements.size).to eq(1)

      assert_equal 1, voucher_creation.settlements.size
      expect(voucher_creation.voucher.is_payment_bank?).to_not be_truthy
    end
  end

  describe 'valid branch' do
    let(:bank_account1) { create(:bank_account)}
    let(:bank_account2) { create(:bank_account)}
    let(:ledger1) { create(:ledger, bank_account_id: bank_account1.id, branch_id: @branch.id)}
    let(:ledger2) { create(:ledger, bank_account_id: bank_account2.id, branch_id: @branch.id)}
    let(:voucher) { build(:voucher, voucher_type: 0)}
    let(:voucher1) { build(:voucher, voucher_type: 1)}
    let(:voucher2) { build(:voucher, voucher_type: 2)}
    let(:debit_particular) { build(:particular, amount: 200, transaction_type: 0, ledger_id: ledger1.id) }
    let(:credit_particular) { build(:particular, amount: 200, transaction_type: 1, ledger_id: ledger2.id) }

    context 'when non client particulars' do
      it 'should return true' do
        voucher.particulars << debit_particular
        voucher.particulars << credit_particular

        voucher1.particulars << debit_particular
        voucher1.particulars << credit_particular

        voucher2.particulars << debit_particular
        voucher2.particulars << credit_particular

        voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                voucher: voucher,
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        voucher_creation1 = Vouchers::Create.new(voucher_type: 1,
                                                voucher: voucher1,
                                                voucher_settlement_type: "default",
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        voucher_creation2 = Vouchers::Create.new(voucher_type: 2,
                                                voucher: voucher2,
                                                voucher_settlement_type: "default",
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)

        expect(voucher_creation.process).to be_truthy
        expect(voucher_creation1.process).to be_truthy
        expect(voucher_creation2.process).to be_truthy
      end

      let(:branch) {create(:branch, address: 'PKR')}
      
      it 'should return true' do
        bank_account1.branch_id = branch.id
        bank_account2.branch_id = branch.id
        ledger1.branch_id = branch.id
        ledger2.branch_id = branch.id
        debit_particular.branch_id = branch.id
        credit_particular.branch_id = branch.id

        voucher.particulars << debit_particular
        voucher.particulars << credit_particular

        voucher1.particulars << debit_particular
        voucher1.particulars << credit_particular

        voucher2.particulars << debit_particular
        voucher2.particulars << credit_particular

        voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                voucher: voucher,
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        voucher_creation1 = Vouchers::Create.new(voucher_type: 1,
                                                 voucher: voucher1,
                                                 voucher_settlement_type: "default",
                                                 tenant_full_name: "Trishakti",
                                                 current_user: User.first,
                                                 selected_fy_code: get_fy_code,
                                                 selected_branch_id: 1)
        voucher_creation2 = Vouchers::Create.new(voucher_type: 2,
                                                 voucher: voucher2,
                                                 voucher_settlement_type: "default",
                                                 tenant_full_name: "Trishakti",
                                                 current_user: User.first,
                                                 selected_fy_code: get_fy_code,
                                                 selected_branch_id: 1)
        expect(voucher_creation.process).to be_truthy
        expect(voucher_creation1.process).to be_truthy
        expect(voucher_creation2.process).to be_truthy
      end
    end

    context 'when client particular present' do
      let(:branch2){create(:branch, address: 'PKR')}
      let(:bank_account) {create(:bank_account)}
      let(:client_account) {create(:client_account, branch_id: branch2.id)}
      let(:ledgerb) { create(:ledger, bank_account_id: bank_account.id)}
      let(:ledgerc) { create(:ledger, client_account_id: client_account.id, branch_id: branch2.id)}
      let(:voucher) { build(:voucher, voucher_type: 0)}
      let(:voucher1) { build(:voucher, voucher_type: 1)}
      let(:voucher2) { build(:voucher, voucher_type: 2)}
      let(:debit_particular) { build(:particular, amount: 100, transaction_type: 0, ledger_id: ledgerb.id) }
      let(:credit_particular) { build(:particular, amount: 100, transaction_type: 1, ledger_id: ledgerc.id, branch_id: branch2.id) }

      it 'should return true' do
        voucher.particulars << debit_particular
        voucher.particulars << credit_particular

        voucher1.particulars << debit_particular
        voucher1.particulars << credit_particular

        debit_particular.transaction_type = 1
        credit_particular.transaction_type = 0

        voucher2.particulars << debit_particular
        voucher2.particulars << credit_particular

        voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                voucher: voucher,
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        voucher_creation1 = Vouchers::Create.new(voucher_type: 1,
                                                voucher: voucher1,
                                                voucher_settlement_type: "default",
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        voucher_creation2 = Vouchers::Create.new(voucher_type: 2,
                                                voucher: voucher2,
                                                voucher_settlement_type: "default",
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        expect(voucher_creation.process).to be_truthy
        expect(voucher_creation1.process).to be_truthy
        expect(voucher_creation2.process).to be_truthy
      end
    end

    context 'when client particulars with different branch' do
      let(:branch1) {create(:branch)}
      let(:branch2) {create(:branch)}
      let(:client1) {create(:client_account, branch_id: branch1.id)}
      let(:client2) {create(:client_account, branch_id: branch2.id)}
      let(:ledger1) {create(:ledger, client_account_id: client1.id, branch_id: branch1.id)}
      let(:ledger2) {create(:ledger, client_account_id: client2.id, branch_id: branch2.id)}
      let(:voucher) {build(:voucher, voucher_type: 0)}
      let(:debit_particular) {build(:particular, amount: 300, transaction_type: 0, ledger_id: ledger1.id, branch_id: branch1.id) }
      let(:credit_particular) {build(:particular, amount: 300, transaction_type: 1, ledger_id: ledger2.id, branch_id: branch2.id) }

      it 'should return true' do
        voucher.particulars << debit_particular
        voucher.particulars << credit_particular
        voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                voucher: voucher,
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        expect(voucher_creation.process).to be_truthy
      end
    end

    context 'when employee particular present' do
      let(:branch) {create(:branch)}
      let(:employee_account) {create(:employee_account, branch_id: branch.id)}
      let(:ledger_e) {create(:ledger, employee_account_id: employee_account.id, branch_id: branch.id)}
      let(:credit_particular) {build(:particular, amount: 200, transaction_type: 1, ledger_id: ledger_e.id, branch_id: branch.id)}

      it 'should return true' do
        voucher.particulars << debit_particular
        voucher.particulars << credit_particular
        voucher_creation = Vouchers::Create.new(voucher_type: 0,
                                                voucher: voucher,
                                                tenant_full_name: "Trishakti",
                                                current_user: User.first,
                                                selected_fy_code: get_fy_code,
                                                selected_branch_id: 1)
        expect(voucher_creation.process).to be_truthy
      end
    end
  end

  after do
    travel_back
  end
end
