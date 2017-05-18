require 'rails_helper'

RSpec.describe Branch, type: :model do
  subject {build(:branch)}
  
  include_context 'session_setup'

  	describe "validations" do
  		it {should validate_presence_of (:code)}
  		it {should validate_presence_of (:address)}
  		it {should validate_uniqueness_of(:code).case_insensitive}
  	end
end