require 'rails_helper'

describe "Transaction" do
  let(:user) {create(:user)}
  before(:each) do
    user
    UserSession.set_console('public')
  end

  after(:each) do
    Warden.test_reset!
  end

  context "signed in user" do
    it "should show the list of message only for the branch" do
      login_as(user, scope: :user)
      client_account = create(:client_account, branch_id: user.branch_id)
      create(:share_transaction, client_account: client_account)
      visit share_transactions_path
      expect(page).to have_content('201611284117936')
      expect(page).to have_content('Displaying 1 share transaction')
    end

    it "should not show the list of message only for the branch" do
      login_as(user, scope: :user)
      branch = create(:branch)
      client_account = create(:client_account, branch_id: branch.id)
      create(:share_transaction, client_account: client_account)

      visit share_transactions_path
      expect(page).to_not have_content('Displaying 1 share transaction')
    end
  end
end