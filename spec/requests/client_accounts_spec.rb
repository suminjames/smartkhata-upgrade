require 'rails_helper'
RSpec.describe "ClientAccounts", type: :request do
  describe "GET /client_accounts" do
    it "works! (now write some real specs)" do
      get client_accounts_path
      visit client_accounts_path
      expect(response).to have_http_status(200)
    end
  end
end
