require 'rails_helper'

RSpec.describe ChequeEntry, type: :model do
  cheque_entry {build(:cheque_entry)}
  bank_account {build(:bank_account)
  

   before do
    # user session needs to be set for doing any activity
    UserSession.user = create(:user)
    UserSession.selected_fy_code = 7374
    UserSession.selected_branch_id =  1
  end
  describe "validations" do
  	it "should be valid" do
  		expect(cheque_entry).to be_valid
  	end

  	it "cheque number should be unique for a bank" do
  		create(:cheque_entry, :cheque_number => 123)
  		cheque_entry.cheque_number=123
  		expect(cheque_entry).not_to be_valid 
  	end
  end
end
