require 'rails_helper'

RSpec.describe Branch, type: :model do
  subject {build(:branch)}
  
  include_context 'session_setup'

  	describe "validations" do
  		subject {build(:branch, code: 'SR', address: 'Utopia')}
  		it {should validate_presence_of (:code)}
  		it {should validate_presence_of (:address)}
  		it {should validate_uniqueness_of (:code)}

  		context "code is present" do
  		  subject{create(:branch)}
  		  it "should  validate_uniqueness_of code" do
  		
  		    new_code = build(:branch, code: subject.code)
  		    expect(new_code).to_not be_valid
  		  end
  		end 	
  	end
end