require 'rails_helper'

RSpec.describe LedgerBalance, type: :model do
  subject { build(:ledger_balance, branch: branch, ledger: ledger) }
  let(:branch) { create(:branch) }
  let(:ledger) { create(:ledger) }
  
  include_context 'session_setup'
  
  describe "validations" do
    it { should validate_uniqueness_of(:branch_id).scoped_to([:fy_code, :ledger_id]) }
  end
  
  describe ".update_opening_closing_balance" do
    context "when opening balance is not blank" do
      it "should return negative opening balance" do
        subject.cr!
        subject.opening_balance = 1000
        subject.update_opening_closing_balance
        expect(subject.opening_balance).to eq(-1000)
      end
    end
    
    context "when ledger balance is a new record " do
      it "closing balance should be equal to opening balance" do
        subject.opening_balance = 500
        subject.update_opening_closing_balance
        expect(subject.closing_balance).to eq(500)
      end
    end
    
    context "when opening balance is changed" do
      context "when opening balance type is dr" do
        subject { create(:ledger_balance, ledger: ledger) }
        it "should return closing balance" do
          subject
          subject.opening_balance_type = 0
          subject.opening_balance = 2000
          subject.closing_balance = 1000
          subject.update_opening_closing_balance
          expect(subject.closing_balance).to eq(3000)
        end
      end
      
      context "when opening balance type is cr" do
        subject { create(:ledger_balance, opening_balance: 3000, ledger: ledger) }
        it "should return closing balance" do
          subject
          subject.opening_balance_type = 1
          subject.opening_balance = 2000
          subject.closing_balance = 1000
          subject.save!
          subject.update_opening_closing_balance
          expect(subject.closing_balance).to eq(-4000)
        end
      end
    end
    
    context "when opening balance is blank" do
      it "should return zero" do
        subject.update_opening_closing_balance
        expect(subject.opening_balance).to eq(0)
      end
    end
  end
  
  describe "#new_with_params" do
    context "when params is present" do
      it "should return ledger balance" do
        params = { branch_id: 1, opening_balance_type: 0, opening_balance: 500 }
        ledger_balance = LedgerBalance.new_with_params(params)
        expect(ledger_balance.opening_balance).to eq(500)
        expect(ledger_balance.branch_id).to eq(1)
      
      end
    end
  end
  
  describe "#update_or_create_org_balance" do
    let(:ledger) { create(:ledger) }
    let(:another_branch){ create(:branch)}
    let(:yet_another_branch){ create(:branch)}
    subject(:ledger_balance) { create(:ledger_balance, ledger: ledger, branch: branch) }
    let(:ledger_balance1) { create(:ledger_balance, ledger: ledger, opening_balance: 2000, branch: another_branch) }
    let(:ledger_balance2) { create(:ledger_balance, ledger: ledger, opening_balance: 1000, branch: yet_another_branch) }
    context "when org balance is not present" do
      it "should create org balance" do
        ledger
        expect { LedgerBalance.update_or_create_org_balance(ledger.id, 7374, User.first.id) }.to change { LedgerBalance.unscoped.count }.by(1)
      end
    end
    
    context "when org balance is present" do
      it "should update org balance" do
        ledger
        subject
        ledger_balance1
        ledger_balance2
        expect { LedgerBalance.update_or_create_org_balance(ledger.id, 7374, User.first.id) }.to change { LedgerBalance.unscoped.count }.by(0)
        expect(subject.reload.opening_balance).to eq(3000)
      end
    end
  end
  
  describe ".formatted_opening_balance" do
    context "when error size is less than 1" do
      it "should return absolute value" do
        subject.opening_balance = -1000
        expect(subject.formatted_opening_balance).to eq(1000)
      end
    end
  end
  
  describe ".check_positive_amount" do
    context "when opening balance type is present" do
      context "and opening balance is negative" do
        context "and opening balance type is not cr" do
          it "should add error" do
            subject.opening_balance = -4000
            subject.opening_balance_type = 0
            subject.check_positive_amount
            expect(subject.errors[:opening_balance]).to include "can't be negative or blank"
          end
        end
      end
    end
    
    context "when opening balance type is not present" do
      context "and opening balance is negative" do
        it "should return opening balance type as cr" do
          subject.opening_balance = -3000
          subject.check_positive_amount
          expect(subject.opening_balance_type).to eq("cr")
        end
      end
    end
  end
  
  describe '.as_json' do
    before do
      allow(subject).to receive(:ledger).and_return(build(:ledger, name: 'Nistha'))
    end
    
    context "when ledgername is passed" do
      it "should include name" do
        expect(subject.as_json(ledger_name: 'Anuj')[:name]).to eq ('Anuj')
      end
    
    end
    context "when ledger name is not passed" do
      it "should get name from ledger" do
        expect(subject.as_json[:name]).to eq ('Nistha')
      end
    end
  end
end
