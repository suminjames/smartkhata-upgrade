require 'rails_helper'

RSpec.describe "esewa_payments/index", type: :view do
  before(:each) do
    assign(:esewa_payments, [
      EsewaPayment.create!(),
      EsewaPayment.create!()
    ])
  end

  it "renders a list of esewa_payments" do
    render
  end
end
