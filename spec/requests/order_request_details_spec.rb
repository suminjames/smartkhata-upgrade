require 'rails_helper'

RSpec.describe "OrderRequestDetails", type: :request do

  include_context 'session_setup'
  describe "GET /order_request_details" do
    it "works! (now write some real specs)" do
      login_as(@user, scope: :user)
      get order_request_details_path
      expect(response).to have_http_status(200)
    end
  end
end
