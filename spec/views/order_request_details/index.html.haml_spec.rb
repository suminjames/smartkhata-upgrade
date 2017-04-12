require 'rails_helper'

RSpec.describe "order_request_details/index", type: :view do
  before(:each) do
    assign(:order_request_details, [
      OrderRequestDetail.create!(
        :quantity => 2,
        :rate => 3,
        :status => 4,
        :isin_info => nil,
        :order_request => nil
      ),
      OrderRequestDetail.create!(
        :quantity => 2,
        :rate => 3,
        :status => 4,
        :isin_info => nil,
        :order_request => nil
      )
    ])
  end

  it "renders a list of order_request_details" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
