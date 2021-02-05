require 'rails_helper'

RSpec.describe "EsewaPayments", type: :request do
  describe "GET /esewa_payments" do
    it "works! (now write some real specs)" do
      get esewa_payments_path
      expect(response).to have_http_status(200)
    end
  end
end
