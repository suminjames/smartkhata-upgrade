require 'rails_helper'

RSpec.describe ChequeEntry, type: :model do
  subject {build(:cheque_entry)}
  
  include_context 'session_setup'


  #  before do
  #   # user session needs to be set for doing any activity
  #   UserSession.user = create(:user)
  #   UserSession.selected_fy_code = 7374
  #   UserSession.selected_branch_id =  1
  # end
  describe "validations" do
  	it "should be valid" do
  		expect(subject).to be_valid
  	end
    it { should validate_presence_of :cheque_number }
    it { should validate_uniqueness_of(:cheque_number).scoped_to([:additional_bank_id, :bank_account_id, :cheque_issued_type]).with_message('should be unique') }

    context "when additional_bank_id absent" do
      subject { build(:cheque_entry, additional_bank_id: nil)}
      it { should validate_presence_of :bank_account }
    end

    context "numericality validation of cheque_number" do
      subject { build(:cheque_entry, skip_cheque_number_validation: nil)}
      it { should validate_numericality_of(:cheque_number) }
    end
  end
end

