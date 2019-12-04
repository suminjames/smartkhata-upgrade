require 'rails_helper'

RSpec.describe "ClientAccounts", type: :request do

  let(:user){create(:user)}
  include_context "session_setup"
  describe "GET /client_accounts" do
    it "works! (now write some real specs)" do
      login_as(@user)
      get client_accounts_path
      expect(response).to have_http_status(200)
    end
  end
end
