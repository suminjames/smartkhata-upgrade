require 'rails_helper'

describe "Securities flow report" do
  let(:user) {create(:user)}
  before(:each) do
    user
    UserSession.set_console('public')
  end

  after(:each) do
    Warden.test_reset!
  end

  context "signed in user" do
    it "should show the list of security flow only for the branch" do
      login_as(user, scope: :user)
      client_account = create(:client_account, branch_id: user.branch_id)
      create(:share_transaction, client_account: client_account)


      allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(Tenant.new)
      allow_any_instance_of(Tenant).to receive(:broker_code).and_return(99)

      visit securities_flow_share_transactions_path
      within("#securities_flows_list") do
        expect(page).to have_content('Test Pvt. Ltd.')
      end
    end

    it "should not show security flow for other branch" do
      login_as(user, scope: :user)
      branch = create(:branch)
      client_account = create(:client_account, branch_id: branch.id)
      create(:share_transaction, client_account: client_account)

      allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(Tenant.new)
      allow_any_instance_of(Tenant).to receive(:broker_code).and_return(99)

      visit securities_flow_share_transactions_path
      expect(page).to have_content('There are no matching securities flows.')
    end
  end
end