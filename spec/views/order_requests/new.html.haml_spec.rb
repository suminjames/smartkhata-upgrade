require 'rails_helper'

RSpec.describe "order_requests/new", type: :view do
  before(:each) do
    assign(:order_request, OrderRequest.new(
      :client_account => nil,
      :date_bs => "MyString"
    ))
  end

  it "renders new order_request form" do
    render

    assert_select "form[action=?][method=?]", order_requests_path, "post" do

      assert_select "input#order_request_client_account_id[name=?]", "order_request[client_account_id]"

      assert_select "input#order_request_date_bs[name=?]", "order_request[date_bs]"
    end
  end
end
