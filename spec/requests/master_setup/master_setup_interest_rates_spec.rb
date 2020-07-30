require 'rails_helper'

RSpec.describe "MasterSetup::InterestRates", type: :request do
  describe "GET /master_setup_interest_rates" do
    it "works! (now write some real specs)" do
      get master_setup_interest_rates_path
      expect(response).to have_http_status(200)
    end
  end
end
