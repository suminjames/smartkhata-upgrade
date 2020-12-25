require 'rails_helper'

RSpec.describe "InterestParticulars", type: :request do
  describe "GET /interest_particulars" do
    it "works! (now write some real specs)" do
      get interest_particulars_path
      expect(response).to have_http_status(200)
    end
  end
end
