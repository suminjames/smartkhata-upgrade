require 'rails_helper'

describe "Client Account", :devise do
  let(:user) {create(:user)}

  before(:each) do
    user
    UserSession.set_console('public')
  end

  after(:each) do
    Warden.test_reset!
  end

  context "signed in user" do
    it "should show the list of client accounts" do
      login_as(user, scope: :user)
      client_account = create(:client_account)
      visit client_accounts_path
      expect(page).to have_content("Client Accounts")
      expect(page).to have_content(client_account.name)
    end
  end
end