require 'rails_helper'

RSpec.describe "order_requests/show", type: :view do
  before(:each) do
    @order_request = assign(:order_request, OrderRequest.create!(
      :date_bs => "Date Bs"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Date Bs/)
  end
end
