require 'rails_helper'

RSpec.describe Particular, type: :model do
	subject{build(:particular)}
  	include_context 'session_setup'

  	describe "validations" do
  		it {should validate_presence_of(:ledger_id)}
  	end
end