require 'rails_helper'

describe "Voucher show" do
  let(:user) {create(:user)}
  let(:tenant) {Tenant}
  
  before(:each) do
    user
    UserSession.set_console('public')
    allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
  end

  after(:each) do
    Warden.test_reset!
  end

  context "when jvr" do
    subject { create(:voucher)}

    before do
      login_as(user, scope: :user)
      particular1 = create(:debit_particular, voucher: subject, branch_id: user.branch_id)
      particular2 =create(:credit_particular, voucher: subject, branch_id: user.branch_id)
      visit voucher_path(subject)
    end

    

    it "should contain company information" do
      expect(page).to have_content('Danphe')
      expect(page).to have_content('Kupondole')
      expect(page).to have_content('Phone: 99999')
      expect(page).to have_content('Fax: 0989')
      expect(page).to have_content('PAN: 9909')
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
      expect(page).to have_content('Prepared By')
      expect(page).to have_content('Approved By')
      expect(page).to have_content('Received By')
    end
  end
end