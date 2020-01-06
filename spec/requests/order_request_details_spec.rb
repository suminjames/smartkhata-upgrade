require 'rails_helper'

RSpec.describe "OrderRequestDetails", type: :request do

  include_context 'session_setup'
  describe "GET /order_request_details" do
    it "works! (now write some real specs)" do
      login_as(@user, scope: :user)
      get order_request_details_path(selected_fy_code: 7677, selected_branch_id: @user.branch_id)oe
      expect(response).to have_http_status(200)
    end
  end
end
