require 'rails_helper'

RSpec.describe Bill, type: :model do
  subject {build(:bill)}
  
  include_context 'session_setup'

  describe "validations" do
  	it {should validate_presence_of (:client_account)}
  end

  it "should be valid" do
  	expect(subject).to be_valid
  end

  it "client_account_id should not be empty" do
  	subject.client_account_id = ''
  	expect(subject).not_to be_valid
  end

  it "client_account_id should not be imaginary" do
  	subject.client_account_id = '3740237'
  	expect(subject).not_to be_valid
  end

  describe ".get_net_share_amount" do
    it "should return total share amount" do
      expect(subject.get_net_share_amount).to eq(subject.share_transactions.not_cancelled_for_bill.sum(:share_amount))
    end
  end

  describe ".get_net_sebo_commission" do
    it "should return total sebo commission" do
      expect(subject.get_net_sebo_commission).to eq(subject.share_transactions.not_cancelled_for_bill.sum(:sebo))
    end
  end

  describe ".get_net_commission" do 
    it "should return total commission" do
      expect(subject.get_net_commission).to eq(subject.share_transactions.not_cancelled_for_bill.sum(:commission_amount))
    end
  end

  describe ".get_name_transfer_amount" do
    it "should get name transfer amount" do
      expect(subject.get_name_transfer_amount).to eq('N/A')
    end
  end

  describe ".get_net_dp_fee" do
    it "should return total net dp fee" do
      fee = subject.share_transactions.not_cancelled_for_bill.sum(:dp_fee);
      if(fee == 0)
        fee = 25
      end
      expect(subject.get_net_dp_fee).to eq(fee)
    end
  end

  describe ".get_net_cgt" do
    it "should return total net cgt" do
      expect(subject.get_net_cgt).to eq(subject.share_transactions.not_cancelled_for_bill.sum(:cgt))
    end
  end

  describe ".get_client" do
    it "should return client associated to this bill" do
      expect(subject.get_client).to eq(ClientAccount.find(subject.client_account_id))
    end
  end

  describe ".age" do
    it "should return the age of purchase bill in days" do
      age = nil
      if(subject.purchase?)
        age = (Date.today - subject.settlement_date).to_i
      end
      expect(subject.age).to eq(age)
    end
  end

  describe ".new_bill_number" do
    it "should get new bill number" do
      bill = Bill.unscoped.where(fy_code: subject.fy_code).order('bill_number DESC').first
      # initialize the bill with 1 if bill is not present
      if(bill.nil?)
        1
      else
        bill.bill_number + 1
      end
    end
  end

  describe ".full_bill_number" do
    it "should get the bill number with fy code prepended"do
      expect(subject.full_bill_number).to eq("#{subject.fy_code}-#{subject.bill_number}")
    end
  end

  describe ".strip_fy_code_from_full_bill_number" do
    it "should return the actual bill number" do
      full_bill_number ||= ''
      full_bill_number_str = full_bill_number.to_s
      hyphen_index = full_bill_number_str.index('-') || -1
      full_bill_number_str[(hyphen_index + 1)..-1]
    end
  end

  describe ".has_incorrect_fy_code?" do
    it do
      true_fy_code = subject.get_fy_code(subject.settlement_date)
      if(true_fy_code != subject.fy_code)
        expect(subject.has_incorrect_fy_code?).to be_truthy
      else
        expect(subject.has_incorrect_fy_code?).not_to be_truthy
      end
        
    end
  end

  describe ".process_bill" do
    it do
      subject.date ||= Time.now
      subject.date_bs ||= ad_to_bs_string(subject.date)
      subject.client_name ||= subject.client_account.name
    end
  end

end