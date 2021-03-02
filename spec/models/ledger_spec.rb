require 'rails_helper'

RSpec.describe Ledger, type: :model do
  subject{build(:ledger, group: group, current_user_id: user.id) }
  let(:user){ create(:user) }
  let(:group){ create(:group) }
  include_context 'session_setup'

  describe "validations" do
    it { should validate_presence_of(:name) }
    #custom validation left

    # it "should raise error" do
    # 	expect{create(:ledger, opening_blnc: -1000)}.to raise_error("can't be negative or blank")
    # end
  end

  describe "#options_for_ledger_type" do
    it "should return options for ledger type" do
      expect(subject.class.options_for_ledger_type).to eq(["client","internal"])
    end
  end

  describe "#options_for_ledger_select" do
    subject{create(:ledger)}
    it "should return options for ledger selection" do
      subject
      expect(subject.class.options_for_ledger_select("by_ledger_id" => subject.id)).to eq([subject])
    end
  end

  describe ".format_client_code" do
    it "should return client code in uppercase" do
      subject.client_code = "  danphe  "
      expect(subject.format_client_code).to eq("DANPHE")
    end
  end

  describe ".format_name" do
    context "when name is present" do
      context "and is stripable" do
        it "should reduce space" do
          subject.name = " danphe"
          expect(subject.format_name).to eq("danphe")
        end
      end

      context "and has more than one space between words" do
        it "should reduce all spaces to single space" do
          subject.name = "danphe     infotech"
          expect(subject.format_name).to eq("danphe infotech")
        end
      end
    end

    context "when name is not present" do
      it "should return same name" do
        expect(subject.format_name).to eq("Ledger")
      end
    end
  end

  describe ".name_from_reserved?" do
    subject{create(:ledger, name: "Purchase Commission")}
    context "when name is reserved in system" do
      it "should raise error" do
        subject
        new_ledger = build(:ledger, name: "Purchase Commission")
        expect(new_ledger).not_to be_valid
        expect(new_ledger.errors[:name]).to include("The name is reserved by system")
      end
    end
  end

  # describe ".update_closing_blnc" do
  #   context "when opening balance is not blank" do
  #     context "and opening balance type is cr" do
  #       it "should return closing balance" do
  #         subject.opening_balance = 800
  #         subject.opening_balance_type = 1
  #         subject.update_closing_blnc
  #         expect(subject.closing_blnc).to eq(-800)
  #         expect(subject.opening_blnc).to eq(-800)
  #       end
  #     end
  #
  #     context "and opening balance type is dr" do
  #       it "should return closing balance" do
  #         subject.opening_blnc = 800
  #         subject.opening_balance_type = 0
  #         subject.update_closing_blnc
  #         expect(subject.closing_blnc).to eq(800)
  #         expect(subject.opening_blnc).to eq(800)
  #       end
  #     end
  #   end
  #   context "when opening balance is blank" do
  #     it "should return opening balance equal to 0" do
  #       expect(subject.opening_blnc).to eq(0)
  #     end
  #   end
  # end

  # this method has been changed on the model level, do necessary or remove
  # describe ".has_editable_balance?" do
  #   context "when particulars size is more than 0" do
  #     it "should return false" do
  #       ledger = create(:ledger)
  #       create(:particular, ledger_id: ledger.id)
  #       expect(ledger.reload.has_editable_balance?).not_to be_truthy
  #     end
  #   end
  #
  #   context "when particulars size is 0"
  #   it "should return true" do
  #     expect(subject.has_editable_balance?).to be_truthy
  #   end
  # end

  describe ".update_custom" do
    it "should return true" do
      allow(subject).to receive(:save_custom).and_return(true)
      expect(subject.update_custom(true, 7374, @branch.id)).to be_truthy
    end
  end

  describe ".create_custom" do
    it "should return true" do
      allow(subject).to receive(:save_custom).and_return(true)
      expect(subject.create_custom(7374, @branch.id)).to be_truthy
    end
  end

  describe ".save_custom" do
    context "when valid" do
      context "and params is nil" do
        #   incase of create
        it "should create ledger balance for org" do
          ledger = build(:ledger)
          ledger.ledger_balances << build(:ledger_balance, branch_id: 1, opening_balance: "5000")
          ledger.ledger_balances << build(:ledger_balance, branch_id: 2, opening_balance: "5000")
          expect { ledger.save_custom(nil, 7374, @branch.id) }.to change {LedgerBalance.unscoped.count }.by(3)
          expect(LedgerBalance.unscoped.where(branch_id: nil, ledger_id: ledger.reload.id).first.closing_balance).to eq(10000)
        end
      end

      context "and params is present" do
        it "should update ledger balance for org" do
          ledger = create(:ledger)
          ledger.ledger_balances << build(:ledger_balance, branch_id: 2, opening_balance: "5000", current_user_id: User.first.id, ledger: ledger)
          ledger_balance = build(:ledger_balance, branch_id: 1, opening_balance: "5000", current_user_id: User.first.id, ledger: ledger)
          ledger.ledger_balances << ledger_balance
          ledger.ledger_balances << build(:ledger_balance, branch_id: nil, opening_balance: "10000", current_user_id: User.first.id, ledger: ledger)

          params = {"ledger_balances_attributes"=>{"0"=>{"opening_balance"=>"6000.0", "opening_balance_type"=>"dr", "branch_id"=>"1", "id"=> ledger_balance.id }}}

          expect { ledger.save_custom(params, 7374, @branch.id) }.to change {LedgerBalance.unscoped.count }.by(0)
          # edit on individual balance should update org balance too
          # org balance has branch id nil
          expect(LedgerBalance.unscoped.where(branch_id: nil, ledger_id: ledger.reload.id).first.closing_balance).to eq(11000)
          expect(LedgerBalance.unscoped.where(branch_id: 1, ledger_id: ledger.reload.id).first.closing_balance).to eq(6000)
        end
      end
    end
    context "when invalid" do
      context "and params is nil" do
        it "should add errors" do
          ledger = build(:ledger)
          ledger.ledger_balances << build(:ledger_balance, branch_id: 1, opening_balance: "5000")
          ledger.ledger_balances << build(:ledger_balance, branch_id: 1, opening_balance: "5000")
          expect(ledger.save_custom).not_to be_truthy
        end
      end
    end
  end

  # this needs to be fixed
  describe ".particulars_with_running_balance" do
    let(:particular1){create(:particular, amount: 1000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
    let(:particular2){create(:particular, amount: 1000, value_date: Date.today - 5.days, transaction_date: Date.today - 10.days)}
    it "should return particulars with running balance" do
      ledger = create(:ledger)
      # particular1
      # particular2
      ledger.particulars << particular2
      ledger.particulars << particular1
      particulars = ledger.particulars_with_running_balance
      expect(particulars.count).to eq(2)
      expect(particulars.first.running_total).to eq(particular2.amount)
      expect(particulars.last.running_total).to eq(particular1.amount + particular2.amount)
    end
  end

  # describe ".positive_amount" do
  #   context "when opening balance is less than 1" do
  #     it "should return error message" do
  #       # subject.opening_blnc = -400
  #       expect(subject.positive_amount).to include("can't be negative or blank")
  #     end
  #   end
  # end

  describe ".closing_balance" do
    context "when session branch is head office" do
      context "and ledger has activities" do
        it "should return correct closing balance" do
          subject
          create(:ledger_balance, ledger: subject, fy_code: 7374, branch_id: nil, opening_balance: 5000, current_user_id: User.first.id)
          expect(subject.closing_balance(7374)).to eq(5000)
        end
        context "and ledger has no activity" do
          it "should return 0 as closing balance" do
            subject
            expect(subject.closing_balance(7374)).to eq(0)
          end
        end
      end
    end

    context "when session branch is branch office" do
      it "should return closing balance" do
        subject
        create(:ledger_balance, ledger: subject, fy_code: 7374, branch_id: 1, opening_balance: 3000)
        expect(subject.closing_balance(7374, @branch.id)).to eq(3000)
      end
    end
  end

  describe ".opening_balance" do
    context "when ledger has ledger balance" do
      let(:ledger_balance) {build(:ledger_balance, opening_balance: 5000)}
      it "should return opening balance" do
        allow(LedgerBalance).to receive(:by_branch_fy_code).and_return([ledger_balance])
        expect(subject.opening_balance(7374, @branch.id)).to eq(5000)
      end
    end

    context "when ledger has no ledger balance" do
      it "should return 0 as opening balance" do
        expect(subject.opening_balance(7374, @branch.id)).to eq(0)
      end
    end

  end

  describe ".dr_amount" do
    context "when ledger has ledger balance" do
      let(:ledger_balance) {build(:ledger_balance, dr_amount: 5000)}
      it "should return dr amount" do
        allow(LedgerBalance).to receive(:by_branch_fy_code).and_return([ledger_balance])
        expect(subject.dr_amount(7374, @branch.id)).to eq(5000)
      end
    end

    context "when ledger has no ledger balance" do
      it "should return 0 as dr amount" do
        expect(subject.dr_amount(7374, @branch.id)).to eq(0)
      end
    end
  end

  describe ".cr_amount" do
    context "when ledger has ledger balance" do
      let(:ledger_balance) {build(:ledger_balance, cr_amount: 5000)}
      it "should return cr amount" do
        allow(LedgerBalance).to receive(:by_branch_fy_code).and_return([ledger_balance])
        expect(subject.cr_amount(7374, @branch.id)).to eq(5000)
      end
    end

    context "when ledger has no ledger balance" do
      it "should return 0 as cr amount" do
        expect(subject.cr_amount(7374, @branch.id)).to eq(0)
      end
    end
  end

  # describe ".descendent_ledgers" do
  #   it "should get descendents ledgers"
  #   # code might not be necessary
  # end

  describe ".name_and_code" do
    context "when client code is present" do
      it "should return client code and name" do
        subject.client_code = "code"
        subject.name = "client"
        expect(subject.name_and_code).to eq("client (code)")
      end
    end

    context "when client code is not present" do
      it "should return only name" do
        subject.name = "client"
        expect(subject.name_and_code).to eq("client")
      end
    end
  end

  describe "#find_similar_to_term" do
    context "when search term is present" do
      context "and client account id is present" do
        context "and client code is present" do
          let(:client_account){create(:client_account, name: "nistha", nepse_code: 'kkl')}
          it "should return attributes for client acount" do

            client_account.ledger.client_code = "code"
            expect(Ledger.find_similar_to_term("ni",nil)).to eq([{:text=>"nistha (KKL)", :id=>"#{client_account.ledger.id}"}])
          end
        end
      end

      # fix this, see how it is defined on the model
      context "when bank account id is present" do
        let(:bank){create(:bank)}
        let(:bank_account){create(:bank_account, bank: bank)}
        it "should return attributes for bank account" do
          bank_account
          expect(Ledger.find_similar_to_term("Ba", nil)).to eq([{:text=>"Bank:#{bank_account.bank.name}(#{bank_account.account_number}) (**Bank Account**)", :id=>"#{bank_account.ledger.id}"}])
        end
      end

      context "when employee account id is present" do
        let(:employee_account){create(:employee_account, name: "john")}
        subject{create(:ledger, name: "ledger1", employee_account_id: employee_account.id)}
        it "should return attributes for employee account" do
          employee_account
          subject.employee_ledger_associations = employee_account.employee_ledger_associations
          expect(Ledger.find_similar_to_term("le", nil)).to eq([{:text=>"ledger1 (**Employee**)", :id=>"#{subject.id}"}])
        end

      end

      context "when vendor account id is present" do
        let(:vendor_account){create(:vendor_account, branch_id: @branch.id)}
        subject{create(:ledger, name: "nistha", vendor_account_id: vendor_account.id)}
        it "should return attributes for vendor account" do
          vendor_account
          subject.vendor_account = vendor_account
          expect(Ledger.find_similar_to_term("ni", nil)).to eq([{:text=>"nistha (**Vendor**)", :id=>"#{subject.id}"}])
        end
      end

      context "when none of these accounts present" do
        subject{create(:ledger)}
        it "should return attributes for internal ledger" do
          subject
          expect(Ledger.find_similar_to_term("Le", nil)).to eq([{:text=>"Ledger (**Internal**)", :id=>"#{subject.id}"}])
        end
      end
    end
  end

  describe ".name_and_identifier" do
    context "when client account id is present" do
      context "and client code is present" do
        subject{build(:ledger, client_code: "code")}
        let(:client_account){create(:client_account, ledger: subject)}
        it "should return name and identifier for client account" do
          subject
          client_account
          expect(subject.name_and_identifier).to eq("Ledger (code)")
        end
      end
    end

    context "when bank account id is present" do
      subject{build(:ledger)}
      let(:bank){create(:bank)}
      let(:bank_account){create(:bank_account, ledger: subject, bank: bank)}
      it "should return name and identifier for bank account" do
        subject
        bank_account
        expect(subject.name_and_identifier).to eq("Bank:#{bank_account.bank.name}(#{bank_account.account_number}) (**Bank Account**)")
      end
    end

    context "when employee account id is present" do
      let(:employee_account){create(:employee_account, name: "john")}
      subject{create(:ledger, name: "ledger1", employee_account_id: employee_account.id)}
      it "should return name and identifier for employee account" do
        employee_account
        subject.employee_ledger_associations = employee_account.employee_ledger_associations
        expect(subject.name_and_identifier).to eq("ledger1 (**Employee**)")
      end

    end

    context "when vendor account id is present" do
      let(:vendor_account){create(:vendor_account, branch_id: @branch.id)}
      subject{create(:ledger, vendor_account_id: vendor_account.id)}
      it "should return name and identifier for vendor account" do
        vendor_account
        subject.vendor_account = vendor_account
        expect(subject.name_and_identifier).to eq("Ledger (**Vendor**)")
      end
    end

    context "when none of these accounts present" do
      subject{create(:ledger)}
      it "should return attributes for internal ledger" do
        subject
        expect(subject.name_and_identifier).to eq("Ledger (**Internal**)")
      end
    end
  end

  describe ".delete_associated_records" do
    subject{create(:ledger)}
    let(:ledger_balance){create(:ledger_balance, ledger: subject)}
    let(:ledger_daily){create(:ledger_daily, date: Date.today, ledger: subject)}
    it "should delete ledger balance" do
      subject
      subject.ledger_balances << ledger_balance
      subject.delete_associated_records
      expect(LedgerBalance.unscoped.where(ledger_id: subject.id).count).to eq(0)
    end

    it "should delete ledger daily" do
      subject
      subject.ledger_dailies << ledger_daily
      subject.delete_associated_records
      expect(LedgerDaily.unscoped.where(ledger_id: subject.id).count).to eq(0)
    end
  end
end
