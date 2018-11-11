require 'rails_helper'

describe Accounts::Bills::ChangeDateService do
  include_context 'session_setup'

  subject {Accounts::Bills::ChangeDateService.new('2017-05-29', '2017-05-28')}

  describe '.get_bills' do
    let(:sales_share_transaction) {create(:sales_share_transaction_processed, bill: create(:sales_bill, net_amount: 115130.6726, date: '2017-05-29' ))}
    before do
      sales_share_transaction
      create(:bill, net_amount: 115130.6726, date: '2017-05-29', branch_id: 2)
    end

    it "should get all bills for the date" do
      expect(subject.get_bills.size).to eq(2)
    end

    context "when branch_id is present" do
      subject {Accounts::Bills::ChangeDateService.new('2017-05-29', '2017-05-28', branch_id: 1)}
      it "should get bills for the date" do
        expect(subject.get_bills.size).to eq(1)
      end
    end

    context "when bill_type is present" do
      subject {Accounts::Bills::ChangeDateService.new('2017-05-29', '2017-05-28', bill_type: :sales)}
      it "should get bills for the date" do
        expect(subject.get_bills.size).to eq(1)
      end
    end
  end


  describe '.process' do
    context "when sales bill" do
      let(:bill) {create(:sales_bill, net_amount: 115130.6726, date: '2017-05-29', branch_id: @branch.id ) }
      let(:voucher) { create(:voucher, date_bs:  '2074-02-15', branch_id: @branch.id)}
      let(:sales_share_transaction) {create(:sales_share_transaction_processed, bill: bill)}
      let(:dr_particular)  { create(:debit_particular, voucher: voucher, branch_id: @branch.id)}
      let(:cr_particular)  { create(:credit_particular, voucher: voucher, branch_id: @branch.id)}

      before do
        sales_share_transaction
        dr_particular
        cr_particular
        voucher.bills_on_creation << bill
        subject.process
      end


      it "should change the dates of the bills" do
        UserSession.selected_branch_id = @branch.id
        expect(sales_share_transaction.reload.bill.date).to eq('2017-05-28'.to_date)
      end

      it "should change voucher date" do
        UserSession.selected_branch_id = @branch.id
        expect(voucher.reload.date).to eq('2017-05-28'.to_date)
      end

      it "should change particular date" do
        expect(dr_particular.reload.transaction_date).to eq('2017-05-28'.to_date)
        expect(cr_particular.reload.transaction_date).to eq('2017-05-28'.to_date)
      end

      it "should patch ledger dailies" do
        UserSession.selected_branch_id = @branch.id
        ledger = dr_particular.ledger.reload
        expect(ledger.ledger_dailies.where(date: '2017-05-29').first).to eq(nil)
        # above give nil simillary below code
        #expect(ledger.reload.ledger_dailies.where(date: '2017-05-28').first.closing_balance).to eq(dr_particular.amount)
      end
    end
  end
end
