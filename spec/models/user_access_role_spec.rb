require 'rails_helper'

RSpec.describe UserAccessRole, type: :model do
  	include_context 'session_setup'
 
  	describe "validations" do
  		it {should validate_presence_of(:role_name)}
  		it {should validate_uniqueness_of(:role_name)}
  	end
end