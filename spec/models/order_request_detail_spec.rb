require 'rails_helper'

RSpec.describe OrderRequestDetail, type: :model do
  include_context "session_setup"

  let(:client_account){create(:client_account, branch: branch, current_user_id: user.id) }
  let(:user){ create(:user) }
  let(:branch){ create(:branch)}
  let(:isin_info){create(:isin_info)}
  let(:order_request){create(:order_request, client_account: client_account)}
  subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id, branch: branch)}


  describe ".can be updated?" do
    it "should return true for pending status" do
      expect(subject.can_be_updated?(client_account.id)).to eq(true)
    end
  end

  describe ".soft_delete" do
    # subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}
    it "should update_status to cancelled" do
      expect {subject.soft_delete}.to change{subject.status}.from("pending").to("cancelled")
    end
  end

  describe ".as_json" do
    # subject{create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id )}
    let(:ledger_balance){create(:ledger_balance, closing_balance: 5000, ledger: ledger)}
    let(:ledger){ create(:ledger)}
    it "adds method to json response" do
      expect(subject.as_json.keys).to include :closing_balance, :client_name, :nepse_code, :company
      expect(subject.as_json[:closing_balance]).to eq(ledger_balance.closing_balance)
      expect(subject.as_json[:client_name]).to eq(client_account.name.as_json)
      expect(subject.as_json[:nepse_code]).to eq(client_account.nepse_code.as_json)
      expect(subject.as_json[:company]).to eq(isin_info.company.as_json)
    end
  end

  describe "test scopes" do
    let(:todays_order){create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id, created_at: Time.now.beginning_of_day, branch: branch )}
    let(:yesterdays_order){create(:order_request_detail, status: 0, isin_info_id: isin_info.id, order_type: 1, order_request_id: order_request.id, created_at: Time.now.beginning_of_day - 1.day, branch: branch)}

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
