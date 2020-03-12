require 'rails_helper'

RSpec.describe UserAccessRole, type: :model do
	include_context 'session_setup'

 subject{ create(:user_access_role) }
  
	describe "validations" do
		it {should validate_presence_of(:role_name)}
		it {should validate_uniqueness_of(:role_name)}
	end
	
 describe "#access_level_types_select" do
   it "should do something" do
     expect(subject.class.access_level_types_select).to eq([["Read Only", "read_only"], ["Read And Write", "read_and_write"]])
   end
 end

end