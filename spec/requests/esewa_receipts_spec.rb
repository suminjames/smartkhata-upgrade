require 'rails_helper'

RSpec.describe "EsewaReceipts", type: :request do
  describe "GET /esewa_receipts" do
    it "works! (now write some real specs)" do
      get esewa_receipts_path
      expect(response).to have_http_status(200)
    end
  end
end
