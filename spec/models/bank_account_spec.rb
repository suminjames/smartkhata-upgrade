require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  subject {create(:bank_account, bank_branch: "kathmandu",account_number:'a2')}
  let(:bank_account_1) {create(:bank_account)}
  include_context 'session_setup'

  describe "validations" do
    it { expect(subject).to be_valid }
    it { should validate_uniqueness_of(:account_number)}
    it { should allow_value('S0M3VALU3').for(:account_number)}
    it { should validate_presence_of(:bank)}
    it { should validate_presence_of(:account_number)}
    it { should validate_presence_of(:bank_branch)}
    it { should_not allow_values(-947, 'quux', '@123#').for(:account_number).with_message('should be numeric or alphanumeric') }

    # it "should not allow opening balance to be negative" do
    #   subject.ledger.opening_blnc = -500
    #   expect(subject).not_to be_valid
    # end
  end

  describe "defaults for payments receipts" do
    it "should change default for payment" do
      subject.save!
      accounts = [subject, bank_account_1]
      accounts.each {|account| account.update_column(:default_for_payment, true) }
      subject.change_default
      accounts.each {|account| account.reload}

      expect(subject.default_for_payment).to be_truthy
      expect(bank_account_1.default_for_payment).to_not be_truthy
    end

    it "should change default for sales" do
      subject.save!
      accounts = [subject, bank_account_1]
      accounts.each {|account| account.update_column(:default_for_receipt, true) }

      subject.change_default
      accounts.each {|account| account.reload}
      expect(subject.default_for_receipt).to be_truthy
      expect(bank_account_1.default_for_receipt).to_not be_truthy
    end
  end


  describe ".bank_name" do
    it "should get bank name" do
      expect(subject.bank_name).to eq(subject.bank.name)
    end
  end

  describe ".name" do
    it "should get formatted bank name" do
      expect(subject.name).to eq("#{subject.bank.bank_code }-#{subject.account_number}")
    end
  end

  describe ".get_current_assets_group" do
    let(:group) { create(:group, name: "Current Assets") }
    it "should get group id" do
      group
      expect(subject.get_current_assets_group).to eq(1)
    end
  end

  describe ".save_custom" do
    it "should create ledger for bank account" do
      allow(subject).to receive(:get_current_assets_group).and_return(5)

      expect(subject.save_custom(7374, 1, User.first.id)).to be_truthy
      expect(subject.ledger.name).to eq("Bank:"+subject.bank.name+"(#{subject.account_number})")
    end
  end

  describe ".ledger_name" do
    it "should get formatted ledger name" do
      expect(subject.ledger_name).to eq("Bank:#{subject.bank.name}(#{subject.account_number})")
    end
  end

  describe ".update_ledger_name" do
    it "should update ledger name" do
      subject.reload
      subject.ledger.name = "something"
      expect { subject.update_ledger_name }.to change { subject.ledger.name }.from("something").to("Bank:#{subject.bank.name}(#{subject.account_number})")
    end
  end



  # describe "validations" do
  #   it { expect(subject).to be_valid }
  #   it { should validate_uniqueness_of(:username).case_insensitive }
  #   it { should validate_uniqueness_of(:email).case_insensitive }
  #
  #   context "email absent but username present" do
  #     before { allow(subject).to receive(:email).and_return(nil) }
  #     it { expect(subject).to be_valid }
  #   end
  #
  #   context "username absent but email present" do
  #     before { allow(subject).to receive(:username).and_return(nil) }
  #     it { expect(subject).to be_valid }
  #   end
  #
  #   it { should validate_length_of(:password).is_at_most(20) }
  #   it { should validate_length_of(:password).is_at_least(4) }
  # end
  #
  # describe "role" do
  #   it "allows the role to updated" do
  #     subject.save
  #     subject.role = subject.class.roles[:admin]
  #     expect(subject).to be_valid
  #   end
  # end

end