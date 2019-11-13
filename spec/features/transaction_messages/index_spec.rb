require 'rails_helper'

describe "Transaction Message" do
  include_context 'feature_session_setup'

  after(:each) do
    Warden.test_reset!
  end

  context "signed in user" do
    it "should show the list of message only for the branch" do
      login_as(@user, scope: :user)
      client_account = create(:client_account, branch_id: @user.branch_id)
      create(:transaction_message, sms_message: 'MyString', client_account: client_account)
      visit transaction_messages_path
      expect(page).to have_content('MyString')
    end

    it "should not show the list of message only for the branch" do
      login_as(@user, scope: :user)
      branch = create(:branch)
      client_account = create(:client_account, branch_id: branch.id)
      create(:transaction_message, sms_message: 'MyString', client_account: client_account)
      visit transaction_messages_path
      expect(page).to_not have_content('MyString')
    end
  end
end