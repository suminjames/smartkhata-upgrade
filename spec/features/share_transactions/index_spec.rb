require 'rails_helper'

describe "Transaction", js: true do
  include_context 'feature_session_setup'

  before(:each) do
    login_as(@user, scope: :user)
  end
  after(:each) do
    Warden.test_reset!
  end

  context "clients branch is equal to user's branch" do
    before do
      client_account = create(:client_account, branch_id: @user.branch_id)
      create(:share_transaction, client_account: client_account)
    end
    it "should show the list of message only for the branch" do
      visit share_transactions_path(selected_fy_code: 7677, selected_branch_id: @user.branch_id)
      expect(page).to have_content('201611284117936')
      expect(page).to have_content('Displaying 1 share transaction')
    end
  end
  
  context "client branch is not equal to users branch" do
    before do
      branch = create(:branch)
      client_account = create(:client_account, branch_id: branch.id)
      create(:share_transaction, client_account: client_account)
    end

    it "should not show the list of message only for the branch" do
      visit share_transactions_path(selected_fy_code: 7677, selected_branch_id: 1)
      expect(page).to_not have_content('Displaying 1 share transaction')
    end
  end
end