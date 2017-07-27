require 'rails_helper'

RSpec.describe BillModule, type: :helper do
  let(:dummy_class) { Class.new { extend BillModule } }
  describe "#get_bills_from_ids" do
    let!(:bill) {create(:bill)}
    it "should return bill" do
      expect(dummy_class.get_bills_from_ids(bill.id)).to eq("")
    end
  end
end

