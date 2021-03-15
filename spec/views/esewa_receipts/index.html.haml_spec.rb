require 'rails_helper'

RSpec.describe "esewa_receipts/index", type: :view do
  before(:each) do
    assign(:esewa_receipts, [
      EsewaReceipt.create!(),
      EsewaReceipt.create!()
    ])
  end

  it "renders a list of esewa_receipts" do
    render
  end
end
