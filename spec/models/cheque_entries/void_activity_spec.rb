require 'rails_helper'

RSpec.describe ChequeEntries::BounceActivity do
  include CustomDateModule

  let(:void_date_bs) { '2073-8-21'}
  let(:cheque_date_ad) { bs_to_ad(void_date_bs) - 1 }
  let(:void_narration) { 'This is a simple void narration' }
  let(:voucher) { create(:voucher) }

  subject { create(:cheque_entry) }

  before do
    # user session needs to be set for doing any activity
    UserSession.user = create(:user)
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id =  1
  end

  describe "invalid fiscal year" do
    it "should return error if fycode is different than current" do
      UserSession.selected_fy_code = 7273
      activity = ChequeEntries::VoidActivity.new(subject, void_date_bs, void_narration,:'trishakti')
      activity.process
      expect(activity.error_message).to_not be_nil
      expect(activity.error_message).to eq('Please select the current fiscal year')
    end
  end

  describe "receipt cheque" do
    it "should not void receipt cheque" do
      subject.update_attribute(:cheque_issued_type, :receipt)
      activity = ChequeEntries::VoidActivity.new(subject, void_date_bs, void_narration,:'trishakti')
      activity.process
      expect(activity.error_message).to eq("The cheque entry cant be made void.")
    end
  end

  it "should void the cheque for voucher with single cheque entry and no bills" do

    subject.update_attribute(:status, :approved)
    dr_particular = create(:debit_particular, voucher: voucher)
    cr_particular = create(:credit_particular, voucher: voucher)

    subject.particulars_on_payment << dr_particular
    subject.particulars_on_receipt << cr_particular
    activity = ChequeEntries::VoidActivity.new(subject, void_date_bs, void_narration,:'trishakti')

    activity.process
    expect(activity.error_message).to be_nil
    expect(subject.void?).to be_truthy
    expect(Voucher.find(voucher.id).reversed?).to be_truthy
    expect(ChequeEntry.find(subject.id).vouchers.uniq.size).to eq(2)
  end


  it "should void the cheque for voucher with multi cheque entry and no bills" do

    cheque_entry = create(:cheque_entry, status: :approved)
    cheque_entry_a = create(:cheque_entry, status: :approved)

    voucher = create(:voucher)
    dr_particular_a = create(:debit_particular, voucher: voucher, amount: 500)
    dr_particular_b = create(:debit_particular, voucher: voucher, amount: 500)
    cr_particular = create(:credit_particular, voucher: voucher, amount: 1000)


    cheque_entry.particulars_on_payment << dr_particular_a
    cheque_entry.particulars_on_receipt << cr_particular

    cheque_entry_a.particulars_on_payment << dr_particular_b
    cheque_entry_a.particulars_on_receipt << cr_particular


    activity = ChequeEntries::VoidActivity.new(cheque_entry, void_date_bs, void_narration,:'trishakti')
    activity.process

    expect(activity.error_message).to be_nil
    expect(cheque_entry.void?).to be_truthy
    expect(Voucher.find(voucher.id).reversed?).to_not be_truthy
    expect(ChequeEntry.find(cheque_entry.id).vouchers.uniq.size).to eq(2)
  end

  it "should void the cheque for voucher with single cheque entry and bill with full amount" do

    cheque_entry = create(:cheque_entry, status: :approved, amount: 5000)
    voucher = create(:voucher)
    dr_particular = create(:debit_particular, voucher: voucher, amount: 5000)
    cr_particular = create(:credit_particular, voucher: @voucher, amount: 5000)

    client_account_a = create(:client_account, ledger: dr_particular.ledger)
    bill_a = create(:sales_bill, client_account: client_account_a, net_amount: 5000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << bill_a

    activity = ChequeEntries::VoidActivity.new(cheque_entry, void_date_bs, void_narration,:'trishakti')
    activity.process

    bill_a = Bill.find(bill_a.id)
    expect(activity.error_message).to be_nil
    expect(bill_a.pending?).to be_truthy
    expect(bill_a.balance_to_pay).to eq(5000)
    expect(cheque_entry.void?).to be_truthy
    expect(Voucher.find(voucher.id).reversed?).to be_truthy
    expect(ChequeEntry.find(cheque_entry.id).vouchers.uniq.size).to eq(2)
  end

  it "should void the cheque for voucher with single cheque entry and bill with partial amount" do

    cheque_entry = create(:cheque_entry, status: :approved, amount: 5000)
    voucher = create(:voucher)
    dr_particular = create(:debit_particular, voucher: voucher, amount: 5000)
    cr_particular = create(:credit_particular, voucher: voucher, amount: 5000)

    client_account_a = create(:client_account, ledger: dr_particular.ledger)
    bill_a = create(:sales_bill, client_account: client_account_a, net_amount: 6000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << bill_a

    activity = ChequeEntries::VoidActivity.new(cheque_entry, void_date_bs, void_narration,:'trishakti')
    activity.process

    bill_a = Bill.find(bill_a.id)
    expect(activity.error_message).to be_nil
    expect(bill_a.partial?).to be_truthy
    expect(bill_a.balance_to_pay).to eq(5000)
    expect(cheque_entry.void?).to be_truthy
    expect(Voucher.find(voucher.id).reversed?).to be_truthy
    expect(ChequeEntry.find(cheque_entry.id).vouchers.uniq.size).to eq(2)
  end

  it "should void the cheque for voucher with multi cheque entry and bills" do

    cheque_entry = create(:cheque_entry, status: :approved, amount: 5000)
    cheque_entry_a = create(:cheque_entry, status: :approved, amount: 4000)

    voucher = create(:voucher)
    dr_particular_a = create(:debit_particular, voucher: voucher, amount: 500)
    dr_particular_b = create(:debit_particular, voucher: voucher, amount: 500)
    cr_particular = create(:credit_particular, voucher: voucher, amount: 1000)

    client_account_a = create(:client_account, ledger: dr_particular_a.ledger)
    bill_a = create(:sales_bill, client_account: client_account_a, net_amount: 6000, balance_to_pay: 0, status: Bill.statuses[:settled])
    client_account_b = create(:client_account, ledger: dr_particular_b.ledger)
    bill_b = create(:sales_bill, client_account: client_account_b, net_amount: 4000, balance_to_pay: 0, status: Bill.statuses[:settled])

    cheque_entry.particulars_on_payment << dr_particular_a
    cheque_entry.particulars_on_receipt << cr_particular

    cheque_entry_a.particulars_on_payment << dr_particular_b
    cheque_entry_a.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << [bill_a, bill_b]


    activity = ChequeEntries::VoidActivity.new(cheque_entry, void_date_bs, void_narration,:'trishakti')
    activity.process

    bill_a = Bill.find(bill_a.id)
    bill_b = Bill.find(bill_b.id)

    expect(activity.error_message).to be_nil
    expect(cheque_entry.void?).to be_truthy
    expect(bill_a.partial?).to be_truthy
    expect(bill_a.balance_to_pay).to eq(5000)
    expect(bill_b.settled?).to be_truthy
    expect(bill_b.balance_to_pay).to eq(0)

    expect(Voucher.find(voucher.id).reversed?).to_not be_truthy
    expect(ChequeEntry.find(cheque_entry.id).vouchers.uniq.size).to eq(2)
  end


end
