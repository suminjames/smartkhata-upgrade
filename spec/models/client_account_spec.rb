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
  	

    it "should  validate_uniqueness_of nepse_code" do
      subject{create(:client_account)}
      new_account = build(:client_account, nepse_code: subject.nepse_code)
      expect(new_account).to_not be_valid
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

end