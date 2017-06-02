require 'rails_helper'

RSpec.describe Settlement, type: :model do
	subject{build(:settlement)}
  	include_context 'session_setup'

  	describe "validations" do
  		it {should validate_presence_of(:date_bs)}
  	end
end