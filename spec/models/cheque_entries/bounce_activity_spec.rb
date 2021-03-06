require 'rails_helper'

RSpec.describe ChequeEntries::BounceActivity do
  include CustomDateModule

  let(:user) { User.first || create(:user) }
  let(:bounce_date_bs) { '2073-8-21'}
  let(:cheque_date_ad) { bs_to_ad(bounce_date_bs) - 1 }
  let(:bounce_narration) { 'This is a simple bounce narration' }
  let(:branch){ create(:branch) }
  let(:bank){create(:bank)}
  let(:bank_account) { create(:bank_account, bank: bank, branch: branch) }
  let(:ledger){ create(:ledger, branch_id: branch.id) }
  let(:additional_bank) { create(:bank) }
  let(:voucher) { create(:voucher, branch: branch) }
  subject { create(:receipt_cheque_entry, bank_account: bank_account, additional_bank: additional_bank) }
  # subject { ChequeEntries::Activity.new(cheque_entry, 'trishakti', User.first.id, branch.id, 7576) }


  describe "invalid fiscal year" do
    it "should return error if fycode is different than current" do
      activity = ChequeEntries::BounceActivity.new(subject, bounce_date_bs, bounce_narration, 'trishakti', user, 1, 7273)
      activity.process
      expect(activity.error_message).to_not be_nil
      expect(activity.error_message).to eq('Please select the current fiscal year')
    end
  end

  describe "payment cheque" do
    it "should not bounce payment cheque" do
      subject.update_attribute(:cheque_issued_type, :payment)
      activity = ChequeEntries::BounceActivity.new(subject, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
      activity.process
      expect(activity.error_message).to eq("The cheque can not be bounced.")
    end
  end

  # voucher with two particulars ie external dr to bank cr
  it "should bounce the cheque for voucher with single cheque entry and no bills" do

    cheque_entry  = create(:receipt_cheque_entry, status: :approved, branch_id: branch.id, bank_account: bank_account, additional_bank: additional_bank)
    dr_particular = create(:bank_particular, voucher: voucher, amount: 5000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)
    cr_particular = create(:credit_particular_non_bank, voucher: voucher, amount: 5000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)
    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
    activity.process
    expect(activity.error_message).to be_nil
    expect(cheque_entry.bounced?).to be_truthy
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end


  it "should bounce the cheque for voucher with single cheque entry and bill with full amount" do
    cheque_entry             = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: cheque_date_ad, branch_id: branch.id, additional_bank: additional_bank, bank: bank)
    cheque_entry.cheque_date = cheque_date_ad

    dr_particular    = create(:bank_particular, voucher: voucher, amount: 5000, ledger: ledger, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)
    cr_particular    = create(:credit_particular_non_bank, voucher: voucher, amount: 5000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)
    client_account_a = create(:client_account, ledger: cr_particular.ledger, branch: branch)
    bill_a = create(:purchase_bill, client_account: client_account_a, net_amount: 5000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << bill_a

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
    activity.process

    expect(activity.error_message).to be_nil
    expect(bill_a.reload.pending?).to be_truthy
    expect(bill_a.balance_to_pay).to eq 5000
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end

  it "should bounce the cheque for voucher with single cheque entry and bill with partial amount" do
    cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 4000, cheque_date: cheque_date_ad, branch_id: branch.id, additional_bank: additional_bank, bank: bank)

    dr_particular    = create(:bank_particular, voucher: voucher, amount: 4000, ledger: ledger, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)
    cr_particular    = create(:credit_particular_non_bank, voucher: voucher, amount: 4000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)
    client_account_a = create(:client_account, ledger: cr_particular.ledger)
    bill_a = create(:purchase_bill, client_account: client_account_a, net_amount: 5000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << bill_a

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
    activity.process

    expect(activity.error_message).to be_nil
    expect(bill_a.reload.partial?).to be_truthy
    expect(bill_a.balance_to_pay).to eq 4000
    expect(cheque_entry.bounced?).to be_truthy
    expect(voucher.reload.reversed?).to be_truthy
    expect(cheque_entry.reload.vouchers.uniq.size).to eq(2)
  end

  it "should bounce the cheque for voucher with single cheque entry and bills with full amount" do
    cheque_entry = create(:receipt_cheque_entry, status: :approved, amount: 5000, cheque_date: cheque_date_ad, branch_id: branch.id, bank_account: bank_account, additional_bank: additional_bank)

    dr_particular    = create(:bank_particular, voucher: voucher, amount: 5000, ledger: ledger, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days, branch_id: branch.id)
    cr_particular    = create(:credit_particular_non_bank, voucher: voucher, amount: 5000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days, branch_id: branch.id)
    client_account_a = create(:client_account, ledger: cr_particular.ledger)
    bill_a = create(:purchase_bill, client_account: client_account_a, net_amount: 3000, balance_to_pay: 0)
    bill_b = create(:purchase_bill, client_account: client_account_a, net_amount: 2000, balance_to_pay: 0)

    cheque_entry.particulars_on_payment << dr_particular
    cheque_entry.particulars_on_receipt << cr_particular

    voucher.bills_on_creation << [ bill_a, bill_b]

    activity = ChequeEntries::BounceActivity.new(cheque_entry, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
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

    # since we are not making any entry to ledger balance on creation
    # we consider only reversal amount for test

    expect(cr_particular.ledger.closing_balance(7374, branch.id)).to eq(5000)
    expect(cr_particular.ledger.particulars.count).to eq(2)
  end

  context "when multiple cheque receipt" do
    before do
      subject.update_attributes(status: :approved, amount: 500, cheque_date: cheque_date_ad, branch_id: branch.id)
      @cheque_entry_a = create(:receipt_cheque_entry, status: :approved, amount: 500, branch_id: branch.id, additional_bank: additional_bank)

      #bank is debit and client is credit
      @cr_particular   = create(:credit_particular_non_bank, voucher: voucher, amount: 1000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days, branch_id: branch.id)
      @dr_particular_a = create(:bank_particular, voucher: voucher, amount: 500, cheque_number: subject.cheque_number, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days, ledger: ledger)
      @dr_particular_b = create(:bank_particular, voucher: voucher, amount: 500, cheque_number: @cheque_entry_a.cheque_number, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days, ledger: ledger)

      subject.particulars_on_payment << @dr_particular_a
      subject.particulars_on_receipt << @cr_particular

      @cheque_entry_a.particulars_on_payment << @dr_particular_b
      @cheque_entry_a.particulars_on_receipt << @cr_particular
      @activity = ChequeEntries::BounceActivity.new(subject, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
      @activity.process
    end

    context "and bouncing single cheque" do
      it "bounces the cheque" do
        expect(@activity.error_message).to be_nil
        expect(subject.bounced?).to be_truthy
      end

      it "reverses the voucher" do
        expect(voucher.reload.reversed?).to be_truthy
        expect(subject.reload.vouchers.uniq.size).to eq(2)
      end

      it "created entry to ledger" do
        ledger = @cr_particular.ledger
        bank_ledger = @dr_particular_a.ledger
        expect(bank_ledger.particulars.count).to eq(2)
        expect(ledger.particulars.count).to eq(2)
        # since we are not making any entry to ledger balance on creation
        # we consider only reversal amount for test
        expect(ledger.reload.closing_balance(7374, branch.id)).to eq(500)
      end
    end

    context "and bouncing second cheque" do
      before do
        @activity = ChequeEntries::BounceActivity.new(@cheque_entry_a, bounce_date_bs, bounce_narration, 'trishakti', user, branch.id, 7374)
        @activity.process
      end

      it "bounces the cheque" do
        expect(@activity.error_message).to be_nil
        expect(@cheque_entry_a.bounced?).to be_truthy
      end

      it "creates another voucher" do
        expect(@cheque_entry_a.reload.vouchers.uniq.size).to eq(2)
      end

      it "created entry to ledger" do
        ledger = @cr_particular.ledger
        bank_ledger = @dr_particular_a.ledger
        expect(ledger.particulars.count).to eq(3)
        expect(bank_ledger.particulars.count).to eq(2)
        # since we are not making any entry to ledger balance on creation
        # we consider only reversal amount for test
        expect(ledger.reload.closing_balance(7374, branch.id)).to eq(1000)
      end
    end
  end

end
