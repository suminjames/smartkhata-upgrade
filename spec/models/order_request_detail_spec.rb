require 'rails_helper'

RSpec.describe OrderRequestDetail, type: :model do
  include_context "session_setup"

  let(:client_account){create(:client_account)}
  let(:isin_info){create(:isin_info)}
  let(:order_request){create(:order_request, client_account: client_account)}


  describe ".can be updated?" do
    subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}
    it "should return true for pending status" do
      expect(subject.can_be_updated?(client_account.id)).to eq(true)
    end
  end

  describe ".soft_delete" do
    subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}
    it "should update_status to cancelled" do
      expect {subject.soft_delete}.to change{subject.status}.from("pending").to("cancelled")
    end
  end

  describe "test scopes" do
    let(:todays_order){create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id, created_at: Time.now.beginning_of_day )}
    let(:yesterdays_order){create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id, created_at: Time.now.beginning_of_day - 1.day )}

    describe "#sorted_by" do
      context "when sort option is desc" do
        it "should order 'order request details' by descending " do
          expect(OrderRequestDetail.sorted_by('created_at_desc').all).to eq([todays_order, yesterdays_order ])
        end
      end

      context "when sort option is invalid" do
        it "should order 'order request details' by ascending " do
          expect{ OrderRequestDetail.sorted_by('created_at_asdf').all }.to raise_error(ArgumentError, "Invalid sort option: \"created_at_asdf\"")
        end
      end
    end
  end

end
