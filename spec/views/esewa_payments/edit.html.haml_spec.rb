require 'rails_helper'

RSpec.describe "esewa_payments/edit", type: :view do
  before(:each) do
    @esewa_payment = assign(:esewa_payment, EsewaPayment.create!())
  end

  it "renders the edit esewa_payment form" do
    render

    assert_select "form[action=?][method=?]", esewa_payment_path(@esewa_payment), "post" do
    end
  end
end
