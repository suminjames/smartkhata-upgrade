require 'rails_helper'

RSpec.describe LedgerBalance, type: :model do
	subject{build(:ledger_balance)}
  	include_context 'session_setup'

  	describe "validations" do
  		it { should validate_uniqueness_of(:branch_id).scoped_to([:fy_code, :ledger_id] )}
  	end
end