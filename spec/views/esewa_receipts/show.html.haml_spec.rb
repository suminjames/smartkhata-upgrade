require 'rails_helper'

RSpec.describe "esewa_receipts/show", type: :view do
  before(:each) do
    @esewa_receipt = assign(:esewa_receipt, EsewaReceipt.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
