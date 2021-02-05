require 'rails_helper'

RSpec.describe "esewa_payments/show", type: :view do
  before(:each) do
    @esewa_payment = assign(:esewa_payment, EsewaPayment.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
