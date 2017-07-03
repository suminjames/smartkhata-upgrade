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

  describe ".get_all_related_bills" do
    subject{create(:client_account)}
      let(:group_member) {create(:client_account, group_leader_id: subject.id)}
    it "should return  all related bills"  do
      
      bill1 = create(:bill, client_account_id: subject.id)
      bill2 = create(:bill, client_account_id: group_member.id )
      expect(subject.get_all_related_bills).to eq([bill1, bill2])
    end
  end

  describe ".get_all_related_bills_ids" do
      subject{create(:client_account)}
      let(:group_member) {create(:client_account, group_leader_id: subject.id)}
    it "should return  all related bills ids"  do
      
      bill1 = create(:bill, client_account_id: subject.id)
      bill2 = create(:bill, client_account_id: group_member.id )
      expect(subject.get_all_related_bill_ids).to eq([subject.id, group_member.id])
    end
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
          allow(SmsMessage).to receive(:messageable_phone_number?).and_return(nil)
          expect(subject.messageable_phone_number).to eq(nil)
        end
    end

    context "when messageable phone number is present" do
      before do
        allow(SmsMessage).to receive(:messageable_phone_number?).and_call_original
      end

      it "should return mobile number" do
        subject.mobile_number = '9841727272'
        allow(SmsMessage).to receive(:messageable_phone_number?).with('9841727272').and_return(true)
        expect(subject.messageable_phone_number).to eq("9841727272")
      end
      
      it "should return phone number" do
        subject.phone = '56524728'
        allow(SmsMessage).to receive(:messageable_phone_number?).with('56524728').and_return(true)
        expect(subject.messageable_phone_number).to eq("56524728")
      end
        
      it "should return phone perm number" do
        subject.phone_perm = '7664535'
        allow(SmsMessage).to receive(:messageable_phone_number?).with('7664535').and_return(true)
        expect(subject.messageable_phone_number).to eq("7664535")
      end  
    end
  end

  describe ".can_be_invited_by_email?" do
    context "when email is present" do
      it "should invite by email" do
         allow(subject).to receive(:user_id).and_return(nil)
        expect(subject.can_be_invited_by_email?).to be_truthy
      end
    end
  end

  describe ".can_assign_username?" do
    context "when nepse code is present" do
      it "should return true" do
        allow(subject).to receive(:user_id).and_return(nil)
        expect(subject.can_assign_username?).to be_truthy
      end
    end
  end

  describe ".has_sufficient_bank_account_info?" do
    context "when bank name and bank account are present" do
        it "should provide bank account info" do
          subject.bank_name = "RBB"
          subject.bank_account = "123"
          expect(subject.has_sufficient_bank_account_info?).to be_truthy
        end
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

  describe ".name_and_nepse_code" do
    context "when nepse code is present" do
      it "should titleize name with nepse code"  do
        subject.nepse_code = "123"
        subject.name = "danphe infotech"
        expect(subject.name_and_nepse_code).to eq("Danphe Infotech (123)")
      end
    end

    context "when nepse code is not present" do
      it "should titleize name"  do
        subject.nepse_code = nil
        subject.name = "danphe infotech"
        expect(subject.name_and_nepse_code).to eq("Danphe Infotech")
      end
    end
  end

  describe ".commaed_contact_numbers" do
    context "when contact numbers are present" do
      it "strip leading or trailing comma " do
        subject.mobile_number = "988654324"
        subject.phone = "666676886"
        subject.phone_perm = "56596776"
        expect(subject.commaed_contact_numbers).to eq("988654324, 666676886, 56596776")
      end
    end

    context "when mobile and phone numbers are present" do
      it "strip leading or trailing comma " do
        subject.mobile_number = "988654324"
        subject.phone = "666676886"
        subject.phone_perm = nil
        expect(subject.commaed_contact_numbers).to eq("988654324, 666676886")
      end
    end
  end

  describe ".pending_bills_path" do
    it "should return path for pending bills" do
      expect(subject.pending_bills_path).to eq("/bills?filterrific%5Bby_bill_status%5D=pending&filterrific%5Bby_client_id%5D=#{subject.id}")
    end
  end

  describe ".share_inventory_path" do
    it "should return share inventory path" do
      expect(subject.share_inventory_path).to eq("/share_transactions?filterrific%5Bby_client_id%5D=#{subject.id}")
    end
  end

  describe ".ledger_closing_balance" do
    # subject{create(:client_account)}
    # let!(:ledger){create(:ledger, client_account_id: subject.id)}
    # let!(:ledger_balance){create(:ledger_balance, ledger_id: ledger.id, closing_balance: 5000)}
    it "should return ledger closing balance" do
      allow_any_instance_of(Ledger).to receive(:closing_balance).and_return(5000)
      expect(subject.ledger_closing_balance).to eq(5000)
    end
  end

  describe "#existing_referrers_names" do
    it "should return existing referrers names" do
      create(:client_account, referrer_name: 'subas')
      create(:client_account, referrer_name: '')   
      create(:client_account, referrer_name: 'nistha')  

      expect(subject.class.existing_referrers_names).to eq(["nistha", "subas"])
    end
  end

  describe "#options_for_client_select" do
    context "when client id isnot present" do
      it "should return empty array" do 
       expect(subject.class.options_for_client_select(:by_client_id => nil)).to eq([])
      end
    end

    context "when client id is present" do
      subject{create(:client_account)}
      it "should return options for client select" do 
       expect(subject.class.options_for_client_select(:by_client_id => subject.id)).to eq([subject])
      end
    end
  end

  describe "#pretty_string_of_filter_identifier" do
    context "when filter identifier isnot present" do
      it "should return empty" do
        expect(subject.class.pretty_string_of_filter_identifier(nil)).to eq("")
      end
    end

    context "when random filter identifier is present" do
      it "should return empty" do
        expect(subject.class.pretty_string_of_filter_identifier("danphe")).to eq("")
      end
    end

    context "when filter identifier is present from array" do
      it "should return pretty string of filter identifier" do
        expect(subject.class.pretty_string_of_filter_identifier("no_mobile_number")).to eq("without Mobile Number")
      end
    end
  end

  describe "#find_similar_to_term" do
    subject {create(:client_account)}
    context "when search term is present and matches name" do
      context "and nepse code is not present" do
        it "should return  attributes with nepse code" do
          subject.update_column(:nepse_code, nil)
          expect(subject.class.find_similar_to_term("De",1)).to eq([:text=> "Dedra Sorenson", :id => "#{subject.id}"])
        end
      end

      context "and nepse code is present" do
        it "should return  attributes with nepse code" do
          subject.update_column(:nepse_code, "123")
          expect(subject.class.find_similar_to_term("De",1)).to eq([:text=> "Dedra Sorenson (123)", :id => "#{subject.id}"])
        end
      end
    end

    context "when search term is present and matches nepse_code" do
      it "should return  attributes with nepse code" do
        subject.update_column(:nepse_code, "nps")
        expect(subject.class.find_similar_to_term("np",1)).to eq([:text=> "Dedra Sorenson (nps)", :id => "#{subject.id}"])
      end
    end

    context "when search term is not present" do
      it "should return  attributes with nepse code" do
        subject.update_column(:nepse_code, "nps")
        expect(subject.class.find_similar_to_term(nil,1)).to eq([:text=> "Dedra Sorenson (nps)", :id => "#{subject.id}"])
      end
    end

  end

  describe '.as_json' do

    it "adds method to json response" do
      expect(subject.as_json.keys).to include :name_and_nepse_code
      expect(subject.as_json[:name_and_nepse_code]).to eq ('Dedra Sorenson (Nepse-1)')
    end
  end

end