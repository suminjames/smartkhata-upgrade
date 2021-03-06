require 'rails_helper'

describe "Voucher show" do
  include_context 'feature_session_setup'

  let(:tenant) {Tenant}

  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
  end

  after(:each) do
    Warden.test_reset!
  end

  shared_examples_for "shows voucher narration" do
    it "shows voucher narration" do
      expect(page).to have_content('Description')
      expect(page).to have_content(subject.desc)
    end
  end
  context "when jvr" do
    subject { create(:voucher, desc: "random text")}

    before do
      login_as(@user, scope: :user)
      particular1 = create(:debit_particular, voucher: subject, branch_id: @user.branch_id)
      particular2 =create(:credit_particular, voucher: subject, branch_id: @user.branch_id)
      visit voucher_path(subject, selected_branch_id: @user.branch_id, selected_fy_code: 7677)
    end

    it_behaves_like "shows voucher narration"

    it "should contain company information" do
      company_info
    end
    it "should show voucher" do
      expect(page).to have_content('Voucher Number: JVR')
    end
    it "should show total" do
      expect(page).to have_content('Total')
      expect(page.first('div#total_dr').text).to eq('5,000.00')
      expect(page.first('div#total_cr').text).to eq('5,000.00')
    end

    it "should show details of user activity" do
      user_activity
    end
  end
  # description's length should be less than 200
  context "when payment voucher" do
    subject{create(:voucher,
                   voucher_type: Voucher.voucher_types["payment"],
                   is_payment_bank: true,
                   desc: "*"*150)}
    before do
      login_as(@user, scope: :user)
      particular1 = create(:debit_particular, voucher: subject, branch_id: @user.branch_id)
      particular2 =create(:credit_particular, voucher: subject, branch_id: @user.branch_id, ledger_type: 1)
      ledger = create(:ledger)
      particular2.ledger = ledger
      visit voucher_path(subject, selected_branch_id: @user.branch_id, selected_fy_code: 7677)
    end
    it_behaves_like "shows voucher narration"
  end
end
