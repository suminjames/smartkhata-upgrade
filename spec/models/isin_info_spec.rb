require 'rails_helper'

RSpec.describe IsinInfo, type: :model do
  	include_context 'session_setup'

  	describe "validations" do
  		it { should validate_presence_of(:company)}
  		it { should validate_presence_of(:isin)}	
  		it { should validate_uniqueness_of(:isin).case_insensitive }
  	end
end