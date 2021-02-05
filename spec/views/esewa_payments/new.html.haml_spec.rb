require 'rails_helper'

RSpec.describe "esewa_payments/new", type: :view do
  before(:each) do
    assign(:esewa_payment, EsewaPayment.new())
  end

  it "renders new esewa_payment form" do
    render

    assert_select "form[action=?][method=?]", esewa_payments_path, "post" do
    end
  end
end
