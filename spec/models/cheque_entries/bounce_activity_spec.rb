require 'rails_helper'

RSpec.describe ChequeEntries::BounceActivity do
  include CustomDateModule

  let(:bounce_date_bs) { '2073-8-21'}
  let(:cheque_date_ad) { bs_to_ad(bounce_date_bs) - 1 }
  let(:bounce_narration) { 'This is a simple bounce narration' }
  let(:voucher) { create(:voucher) }
  subject { create(:receipt_cheque_entry) }

  before do
    # user session needs to be set for doing any activity
    UserSession.user = create(:user)
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id =  1
  end

  describe "invalid fiscal year" do
    it "should return error if fycode is different than current" do
      UserSession.selected_fy_code = 7273
      activity = ChequeEntries::BounceActivity.new(subject, bounce_date_bs, bounce_narration, 'trishakti')
      activity.process
      expect(activity.error_message).to_not be_nil
      expect(activity.error_message).to eq('Please select the current fiscal year')
    end
  end

  describe "payment cheque" do
    it "should not bounce payment cheque" do
      subject.update_attribute(:cheque_issued_type, :payment)
      activity = ChequeEntries::BounceActivity.new(subject, bounce_date_bs, bounce_narration, 'trishakti')
      activity.process
      expect(activity.error_message).to eq("The cheque can not be bounced.")
    end
  end

  # voucher with two particulars ie external dr to bank cr
  it "should bounce the cheque for voucher with single cheque entry and no bills" do

    cheque_entry = create(:receipt_cheque_entry, status: :approved)
    dr_particular = create(:debit_particular, voucher: voucher)
    cr_particular = create(:credit_particular, voucher: voucher)
    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti')
    activity.process
    expect(activity.error_message).to be_nil
    expect(cheque_entry.bounced?).to be_truthy
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end


  it "should bounce the cheque for voucher with single cheque entry and bill with full amount" do
    cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: cheque_date_ad)
    cheque_entry.cheque_date = cheque_date_ad
    dr_particular = create(:debit_particular, voucher: voucher, amount: 5000)
    cr_particular = create(:credit_particular, voucher: voucher, amount: 5000)

    client_account_a = create(:client_account, ledger: dr_particular.ledger)
    bill_a = create(:purchase_bill, client_account: client_account_a, net_amount: 5000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << bill_a

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti')
    activity.process

    expect(activity.error_message).to be_nil
    expect(bill_a.reload.pending?).to be_truthy
    expect(bill_a.balance_to_pay).to eq 5000
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end

  it "should bounce the cheque for voucher with single cheque entry and bill with partial amount" do
    cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 4000, cheque_date: cheque_date_ad)
    dr_particular = create(:debit_particular, voucher: voucher, amount: 4000)
    cr_particular = create(:credit_particular, voucher: voucher, amount: 4000)

    client_account_a = create(:client_account, ledger: dr_particular.ledger)
    bill_a = create(:purchase_bill, client_account: client_account_a, net_amount: 5000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << bill_a

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti')
    activity.process

    expect(activity.error_message).to be_nil
    expect(bill_a.reload.partial?).to be_truthy
    expect(bill_a.balance_to_pay).to eq 4000
    expect(cheque_entry.bounced?).to be_truthy
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end

  it "should bounce the cheque for voucher with single cheque entry and bills with full amount" do
    cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: cheque_date_ad)
    dr_particular = create(:debit_particular, voucher: voucher, amount: 5000)
    cr_particular = create(:credit_particular, voucher: voucher, amount: 5000)

    client_account_a = create(:client_account, ledger: dr_particular.ledger)
    bill_a = create(:purchase_bill, client_account: client_account_a, net_amount: 3000, balance_to_pay: 0)
    bill_b = create(:purchase_bill, client_account: client_account_a, net_amount: 2000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << [ bill_a, bill_b]

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti')
    activity.process

    bill_a = Bill.find(bill_a.id)
    bill_b = Bill.find(bill_b.id)

    expect(activity.error_message).to be_nil
    expect(bill_a.reload.pending?).to be_truthy
    expect(bill_a.balance_to_pay).to eq 3000
    expect(bill_b.reload.pending?).to be_truthy
    expect(bill_b.balance_to_pay).to eq 2000
    expect(cheque_entry.bounced?).to be_truthy
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end

  context "multiple cheque receipt" do
    it "should bounce cheque for voucher with multi cheque entry for single client" do
      subject.update_attributes(status: :approved, amount: 500, cheque_date: cheque_date_ad)
      cheque_entry_a = create(:receipt_cheque_entry, status: :approved, amount: 500)

      dr_particular = create(:debit_particular, voucher: voucher, amount: 1000)

      cr_particular_a = create(:credit_particular, voucher: voucher, amount: 500, cheque_number: subject.cheque_number)
      cr_particular_b = create(:credit_particular, voucher: voucher, amount: 500)

      subject.particulars_on_payment << dr_particular
      subject.particulars_on_receipt << cr_particular_a

      cheque_entry_a.particulars_on_payment << dr_particular
      cheque_entry_a.particulars_on_receipt << cr_particular_b

      activity = ChequeEntries::BounceActivity.new(subject, bounce_date_bs, bounce_narration, 'trishakti')
      activity.process

      expect(activity.error_message).to be_nil
      expect(subject.bounced?).to be_truthy
      expect(voucher.reload.reversed?).to be_truthy
    end
  end

end
