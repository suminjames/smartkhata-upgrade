require 'rails_helper'

RSpec.describe Bank, type: :model do
  subject {build(:bank)}
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
	
	  it "bank code should not be empty" do
  		subject.bank_code=''
  		expect(subject).not_to be_valid
  	end
  	
  	it "bank code should not be blank" do
  		subject.bank_code='  '
  		expect(subject).not_to be_valid
  	end

  	it "bank code should not be duplicate" do
  		create(:bank, :name => 'MyString')
  		should_not allow_value('MyString').for(:name)
  	end

    describe ".code_and_name" do
      it "should get bank_code and name" do
        expect(subject.code_and_name).to eq("#{subject.bank_code} (#{subject.name})")
      end
    end 
  end
end