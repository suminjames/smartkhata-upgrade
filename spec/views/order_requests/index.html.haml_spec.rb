require 'rails_helper'

RSpec.describe "order_requests/index", type: :view do
  before(:each) do
    assign(:order_requests, [
      OrderRequest.create!(
        :client_account => nil,
        :date_bs => "Date Bs"
      ),
      OrderRequest.create!(
        :client_account => nil,
        :date_bs => "Date Bs"
      )
    ])
  end

  it "renders a list of order_requests" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Date Bs".to_s, :count => 2
  end
end
