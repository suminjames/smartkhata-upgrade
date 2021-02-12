require 'rails_helper'

RSpec.describe "esewa_receipts/new", type: :view do
  before(:each) do
    assign(:esewa_receipt, EsewaReceipt.new())
  end

  it "renders new esewa_receipt form" do
    render

    assert_select "form[action=?][method=?]", esewa_receipts_path, "post" do
    end
  end
end
