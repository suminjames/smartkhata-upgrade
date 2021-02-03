require 'rails_helper'

RSpec.describe ChequeEntry, type: :model do
  subject { build(:cheque_entry, bank_account: bank_account, additional_bank: bank) }
  let(:bank) { create(:bank) }
  let(:bank_account) { create(:bank_account, branch: branch, bank: bank) }
  let(:branch) { create(:branch) }
  
  include_context 'session_setup'
  
  #  before do
  #   # user session needs to be set for doing any activity
  #   UserSession.user = create(:user)
  #   UserSession.selected_fy_code = 7374
  #   UserSession.selected_branch_id =  1
  # end
  describe "validations" do
  	it "should be valid" do
  		expect(subject).to be_valid
  	end
    it { should validate_presence_of :cheque_number }
    it { should validate_uniqueness_of(:cheque_number).scoped_to([:additional_bank_id, :bank_account_id, :cheque_issued_type]).with_message('should be unique') }

    # Additional Bank ID can't be nil
    # context "when additional_bank_id absent" do
    #   subject { build(:cheque_entry, bank: bank, additional_bank_id: nil)}
    #   it { should validate_presence_of :bank_account }
    # end

    context "numericality validation of cheque_number" do
      subject { build(:cheque_entry, bank: bank, additional_bank: bank, skip_cheque_number_validation: nil)}
      it { should validate_numericality_of(:cheque_number) }
    end
  end

  describe "#find_beneficiary_name_similar_to_term" do
    subject{create(:cheque_entry, bank: bank, additional_bank: bank)}
    it "should return beneficiary name when matched" do
      subject
      expect(ChequeEntry.find_beneficiary_name_similar_to_term('su')).to eq([{:text=>"subas", :id=>"subas"}])
    end
    it "should not return beneficiary name when  not matched" do
      subject
      expect(ChequeEntry.find_beneficiary_name_similar_to_term('subr')).to eq([])
    end

  end

  describe "#options_for_bank_account_select" do
    let(:bank_account1) { create(:bank_account, branch: branch, bank: bank) }
    let(:bank_account2) { create(:bank_account, branch: branch, bank: bank) }

    before do
      bank_account2.bank.update_column(:name, 'alpha')
      bank_account1.bank.update_column(:name, 'beta')
    end

    context "when view all branch is selected" do
      it "should return both banks" do
        expect(ChequeEntry.options_for_bank_account_select.count).to eq(2)
      end
      it "should return both banks in order by name" do
        expect(ChequeEntry.options_for_bank_account_select.first).to eq(bank_account2)
      end
    end

    context "when view  branch is selected" do
      it "should return bank" do
        expect(ChequeEntry.options_for_bank_account_select(branch.id).count).to eq(2)
      end
      it "should return bank in order by name" do
        expect(ChequeEntry.options_for_bank_account_select(branch.id).first).to eq(bank_account2)
      end
    end
  end

  describe "#options_for_beneficiary_name" do
    context "when filterrific params is not present" do
      it "should return empty array" do
        expect(subject.class.options_for_beneficiary_name(nil)).to eq([])
      end
    end

    context "when filterrific params is present" do
      it "should return baneficiary name array" do
       expect(subject.class.options_for_beneficiary_name({:by_name => "nistha"})).to eq([])
      end
    end

    context "when filterrific params is present" do
      it "should return baneficiary name array" do
       expect(subject.class.options_for_beneficiary_name({:by_beneficiary_name => "nistha"})).to eq(['nistha'])
      end
    end
  end

  describe ".can_print_cheque?" do
    it "should return false if cheque issued type is receipt " do
      subject.receipt!
      expect(subject.can_print_cheque?).not_to be_truthy
    end

    it "should return false if print status is printed" do
      subject.printed!
      expect(subject.can_print_cheque?).not_to be_truthy
    end

    it "should return false if cheque status is unassigned" do
      subject.unassigned!
      expect(subject.can_print_cheque?).not_to be_truthy
    end


    it "should return false if cheque status is void" do
      subject.void!
      expect(subject.can_print_cheque?).not_to be_truthy
    end
  end

  describe ".associated_bank_particulars" do
    let(:particular) {create(:particular, cheque_number: subject.cheque_number, value_date: Date.today - 5.days, transaction_date: Date.today - 15.days)}
    it "should return associated bank particulars" do
      subject.particulars << particular
      subject.save

      expect(subject.associated_bank_particulars).to eq([particular])
    end
  end
end

