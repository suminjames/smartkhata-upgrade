require 'rails_helper'

RSpec.describe Ledger, type: :model do
	subject{build(:ledger)}
  	include_context 'session_setup'

  	describe "validations" do
  		it { should validate_presence_of (:name)}
  	end
end
