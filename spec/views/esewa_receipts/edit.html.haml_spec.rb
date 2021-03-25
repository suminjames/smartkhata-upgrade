require 'rails_helper'

RSpec.describe "esewa_receipts/edit", type: :view do
  before(:each) do
    @esewa_receipt = assign(:esewa_receipt, EsewaReceipt.create!())
  end

  it "renders the edit esewa_receipt form" do
    render

    assert_select "form[action=?][method=?]", esewa_receipt_path(@esewa_receipt), "post" do
    end
  end
end
