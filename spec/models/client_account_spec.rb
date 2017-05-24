require 'rails_helper'

RSpec.describe ClientAccount, type: :model do
  subject {build(:client_account)
  }

  include_context 'session_setup'

   # before do
   #  # user session needs to be set for doing any activity
   #  UserSession.user = create(:user)
   #  UserSession.selected_fy_code = 7374
   #  UserSession.selected_branch_id =  1
   # end
  describe "validations" do
  	it "should be valid" do
  		expect(subject).to be_valid
  	end

  	it "branch id should always be present if multiple branches are present" do
  	   create(:branch)
  		subject.branch_id = nil
  		expect(subject).not_to be_valid
  	end

  	context "when nepse code is not present" do
  		subject { build(:client_account_without_nepse_code)}

  		it { should validate_presence_of (:name)}
  		it { should validate_presence_of :citizen_passport}
  		it { should validate_presence_of :dob}
  		it { should validate_presence_of :father_mother}
  		it { should validate_presence_of :granfather_father_inlaw}
  		it { should validate_presence_of :city_perm}
  		it { should validate_presence_of :address1_perm}
  		it { should validate_presence_of :state_perm}
  		it { should validate_presence_of :country_perm}

  		# context ""
  	end

  	context "when date is in YYYY-MM-DD format" do
  	 	it{ should allow_value("2074-01-13").for(:dob)}
  	 	it{ should allow_value("2074-01-10").for(:citizen_passport_date)}
  	end

  	it { should allow_value("hello@example.com").for(:email)}
  	it { should validate_numericality_of(:mobile_number)}

  	context "when any bank field is present" do
      # context "when bank account is present" do
      #   subject { build(:client_account, bank_account: '09999')}
      #   it { should validate_presence_of (:bank_name)}
      #   it { should validate_presence_of (:bank_address)}
      # end
      before do
        # allow(subject).to receive(:any_bank_field_present?).and_return(true)
        allow_any_instance_of(ClientAccount).to receive(:any_bank_field_present?).and_return(true)
      end

      it { should validate_presence_of (:bank_name)}
      it { should validate_presence_of (:bank_account)}
      it { should validate_presence_of (:bank_address)} 
	  end

    context "when bank name and address is present" do
        subject { build(:client_account, bank_name: 'adf', bank_address: 'asdf')}
        it { expect(subject).not_to allow_values(-1,'qu-o','#ioo').for(:bank_account) } 
        it { should allow_values(5466461, 'ghgbb1').for(:bank_account) } 
    end
  	

    context "when nepse code is present" do
      subject{create(:client_account)}
      it "should  validate_uniqueness_of nepse_code" do
  
        new_account = build(:client_account, nepse_code: subject.nepse_code)
        expect(new_account).to_not be_valid
      end
    end 
    it "nepse code can be blank" do
      subject.nepse_code = ''
      expect(subject).to be_truthy
      subject.save!
    end
  end



  describe ".any_bank_field_present" do
    it "should return true if bank_account present" do
      subject.bank_account = "456"
      expect(subject.any_bank_field_present?).to be_truthy
    end
    it "should return true if bank_name present" do
      subject.bank_name = "RBB"
      expect(subject.any_bank_field_present?).to be_truthy
    end
    it "should return true if bank_address present" do
      subject.bank_address = "lalitpur"
      expect(subject.any_bank_field_present?).to be_truthy
    end
  end

  describe ".format_nepse_code" do
    it "should store code in uppercase and remove space" do
      subject.nepse_code = " danphe "
     expect(subject.format_nepse_code).to eq("DANPHE")
    end
  end

  describe ".format_name" do
    it "should remove space" do
      subject.name = " danphe"
      expect(subject.format_name).to eq("danphe")
    end

    it "should reduce all whitespace to single space" do
      subject.name = "danphe            infotech"
      expect(subject.format_name).to eq("danphe infotech")
    end

    it "should return same" do
      subject.name = "danphe"
      expect(subject.format_name).to eq("danphe")
    end
  end

  describe ".skip_or_nepse_code_present?" do
    subject {build(:client_account, nepse_code: nil, skip_validation_for_system: nil)}

    it "should return false" do
      expect(subject.skip_or_nepse_code_present?).not_to be_truthy
    end


    context "when nepse_code present" do
      it "should return true" do
        subject.nepse_code = 'adf'
        expect(subject.skip_or_nepse_code_present?).to be_truthy
      end
    end

    context "when skip_validation_for_system present" do
      it "should return true" do
        subject.skip_validation_for_system = true
        expect(subject.skip_or_nepse_code_present?).to be_truthy
      end
    end
  end

  describe ".bank_details_present?" do
    it "should have errors" do
      subject.bank_account = "gutft"
      subject.bank_name = " "
      
      subject.bank_details_present?
      expect(subject.errors[:bank_account]).to include 'Please fill the required bank details'
    end
  end

  describe ".find_or_create_ledger" do
    let(:ledger){build(:ledger)}
    context "when ledger is present" do
      
      it "should be true for ledger present" do
        allow(subject).to receive(:ledger).and_return(ledger)
        expect(subject.find_or_create_ledger).to eq(ledger)
      end
    end

    context "when ledger isnot present" do
      it "should return true" do 
        allow(subject).to receive(:create_ledger).and_return(ledger)
        expect(subject.find_or_create_ledger).to eq(ledger)
      end
    end
  end

  describe ".create_ledger" do
    context "when nepse code is present" do
      it "should create a ledger with same name" do
        expect(subject.create_ledger.name).to eq(subject.name)
      end

      it "should create a ledger with same id" do
        expect(subject.create_ledger.client_account_id).to eq(subject.id)
      end

      it "should assign client to clients group" do
        client_group = Group.find_or_create_by!(name: "Clients")
        expect(subject.create_ledger.group_id).to eq(client_group.id)
      end
    end

    context "when nepse code is present" do
      subject{build(:client_account, nepse_code: "tdytf")}
      it "should match the value of client code to nepse code" do
        expect(subject.create_ledger.client_code).to eq("TDYTF")
      end
    end
  end

  describe ".assign group" do
    it ""
  end

  describe ".get_current_valuation" do
    it "should return current evaluation" 

  end

  describe ".get_group_members_ledgers" do
    subject{create(:client_account)}
    
    it "should return group member ledgers" do
      group_member = create(:client_account, group_leader_id: subject.id)
      expect(subject.get_group_members_ledgers).to include group_member.ledger
    end
  end

  describe ".get_group_members_ledger_ids" do
    subject{create(:client_account)}
    it "should return group member ledger ids" do
      group_member = create(:client_account, group_leader_id: subject.id)
      expect(subject.get_group_members_ledger_ids).to include group_member.ledger.id
    end
  end

  describe ".messageable_phone_number" do
    context "when messageable phone number isnot present" do
        it "should return nil" do
          allow(subject).to receive(:messageable_phone_number).and_return(nil)
          expect(subject.messageable_phone_number).to eq(nil)
        end
    end

    context "when messageable phone number is present" do
        it "should return mobile number" do
          allow(subject).to receive(:messageable_phone_number).and_return("9841727272")
          expect(subject.messageable_phone_number).to eq("9841727272")
        end
    end
  end

end