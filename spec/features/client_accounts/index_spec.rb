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

  context "signed in user", js: true do
    it "should show the list of client accounts" do
      login_as(user, scope: :user)
      client_account = create(:client_account)
      visit client_accounts_path
      expect(page).to have_content("Client Accounts")
      expect(page).to have_content(client_account.name)

      expect(page.all('#client_account_list tbody tr').length).to eq(1)

      within("#client_account_list tbody tr") do
        expect(all("input[type='checkbox']").length).to eq(1)
        expect(first("input[type='checkbox']")['class']).to eq('email')
        find("input[type='checkbox']").set(true)
      end

      click_on "Create / Invite Selected"
      expect(page).to have_content("Action completed successfully")

    end
  end
end