require 'rails_helper'

RSpec.describe "MergeRebates", type: :request do
  describe "GET /merge_rebates" do
    it "works! (now write some real specs)" do
      get merge_rebates_path
      expect(response).to have_http_status(200)
    end
  end
end
