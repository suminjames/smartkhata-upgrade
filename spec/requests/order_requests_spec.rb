require 'rails_helper'

RSpec.describe "OrderRequests", type: :request do
  describe "GET /order_requests" do
    it "works! (now write some real specs)" do
      get order_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
