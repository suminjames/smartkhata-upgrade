require 'rails_helper'

RSpec.describe "order_request_details/show", type: :view do
  before(:each) do
    @order_request_detail = assign(:order_request_detail, OrderRequestDetail.create!(
      :quantity => 2,
      :rate => 3,
      :status => 4,
      :isin_info => nil,
      :order_request => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
