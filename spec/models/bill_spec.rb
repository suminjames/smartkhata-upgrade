require 'rails_helper'

RSpec.describe Bill, type: :model do
  # we need share transactions for methods
  subject {create(:sales_bill_with_transaction)}
  
  include_context 'session_setup'

  describe "validations" do
    it { expect(subject).to be_valid }
  	it {should validate_presence_of (:client_account)}
  end
  # it "client_account_id should not be empty" do
  # 	subject.client_account_id = ''
  # 	expect(subject).not_to be_valid
  # end

  # it "client_account_id should not be imaginary" do
  # 	subject.client_account_id = '3740237'
  # 	expect(subject).not_to be_valid
  # end

  describe ".get_net_share_amount" do
    it "should return total share amount" do
      expect(subject.get_net_share_amount).to eq(115810.0)
    end
  end

  

  describe ".get_net_sebo_commission" do
    it "should return total sebo commission" do
      expect(subject.get_net_sebo_commission).to eq(17.315)
    end
  end

  describe ".get_net_commission" do 
    it "should return total commission" do
      expect(subject.get_net_commission).to eq(636.955)
    end
  end

  describe ".get_name_transfer_amount" do
    it "should get name transfer amount" do
      expect(subject.get_name_transfer_amount).to eq('N/A')
    end
  end

  describe ".get_net_dp_fee" do
    it "should return total net dp fee" do
      expect(subject.get_net_dp_fee).to eq(25)
    end
  end

  describe ".get_net_cgt" do
    it "should return total net cgt" do
      expect(subject.get_net_cgt).to eq(1)
    end
  end

  describe ".get_client" do
    it "should return client associated to this bill" do
      expect(subject.get_client).to eq(ClientAccount.find(subject.client_account_id))
    end
  end

  describe ".age" do
    context "when sales_bill" do
      it "should return nil" do
        expect(subject.age).to eq(nil)
      end
    end
    context "when purchase" do
      it "should return date" do 
        age = (Date.today - subject.settlement_date).to_i
        expect(subject.age).to eq(age)
      end
    end
  end

  describe "#new_bill_number" do
    context "when no previous bills are present for fycode" do
      it "should return 1" do
        expect(subject.class.new_bill_number(12)).to eq(1)
      end
    end
    context "when previous bills are present for fycode" do
      it "should get new bill number" do
        expect(subject.class.new_bill_number(subject.fy_code)).to eq(subject.bill_number + 1 )
      end
    end  
  end

  describe ".full_bill_number" do
    it "should get the bill number with fy code prepended"do
      expect(subject.full_bill_number).to eq("#{subject.fy_code}-#{subject.bill_number}")
    end
  end

  describe "#strip_fy_code_from_full_bill_number" do
    context "when fycode is prepended" do
      it "should return bill number" do
        expect(subject.class.strip_fy_code_from_full_bill_number('7374-1509')).to eq('1509')
      end
    end 
    context "when fycode is not prepended" do
      it "should return bill number" do
        expect(subject.class.strip_fy_code_from_full_bill_number('1509')).to eq('1509')
      end
    end  
  end

  # make provisional(sales bill only)
  # wrong date expect error raise
  # test for provisional base_price
  # test for bill without share transactions
  # test for bill with bill date different to share transactions
  # make the share transaction with some bill id and test the failure
  # verify the final lines 250 253
  describe ".make_provisional" do
    describe "validations" do
      context "when date is invalid" do
        subject { build(:bill, date_bs: '67544') } 
        it "should be invalid " do
          expect(subject.make_provisional.errors[:date_bs]).to include 'Invalid Transaction Date. Date format is YYYY-MM-DD'
        end
      end

      context "when provisional base_price is blank" do
        subject { build(:bill) } 
        it "should be have errors " do
          expect(subject.make_provisional.errors[:provisional_base_price]).to include 'Invalid Base Price'
        end
      end
      

       context "when share transaction size is less than 1" do
        subject { build(:bill, provisional_base_price: 100) } 
        it "should be have errors " do
          expect(subject.make_provisional.errors[:date_bs]).to include 'No Sales Transactions Found'
        end
      end

      context "when share transaction bill is present" do
        subject { build(:bill, provisional_base_price: 100) } 

        it "should be have errors " do
          create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), bill: create(:bill), client_account_id: subject.client_account_id)

          expect(subject.make_provisional.errors[:date_bs]).to include 'Sales Bill already Created for this date'
        end
      end
    end

    context "when valid" do
      subject { build(:bill, provisional_base_price: 100) } 

      before do
        create(:sales_share_transaction, date: subject.bs_to_ad(subject.date_bs), client_account_id: subject.client_account_id)
      end

      it "should assign correct date" do
        date = subject.bs_to_ad(subject.date_bs)
        expect(subject.make_provisional.date).to eq date
      end
    end

  end

  # requires processing
  # has incorrect fy code? true for current false for settlement date '2072-01-01'
  describe ".requires_processing?" do
    it "should return true if bill is pending" do
      subject.pending!
      expect(subject.requires_processing?).to be_truthy
    end

     it "should return true if bill is partial" do
      subject.partial!
      expect(subject.requires_processing?).to be_truthy
    end

     it "should return false if bill is settled" do
      subject.settled!
      expect(subject.requires_processing?).not_to be_truthy
    end
  end

  describe ".has_incorrect_fy_code?" do
    context "when incorrect fy_code " do
      it "should return true" do
        allow(subject).to receive(:get_fy_code).and_return(234)
        expect(subject.has_incorrect_fy_code?).to be_truthy
      end
    end

    context "when correct fy_code " do
      it "should return false" do
        allow(subject).to receive(:get_fy_code).and_return(7374)
        expect(subject.has_incorrect_fy_code?).not_to be_truthy
      end
    end
      # it {expect(subject.get_fy_code(subject.settlement_date)).not_to be_truthy}
      # it {expect(subject.get_fy_code(subject.bs_to_ad('2072-01-01'))).to be_truthy}

  end

  describe ".process_bill" do
    
  end

end