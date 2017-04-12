require 'rails_helper'

RSpec.describe "order_requests/edit", type: :view do
  before(:each) do
    @order_request = assign(:order_request, OrderRequest.create!(
      :client_account => nil,
      :date_bs => "MyString"
    ))
  end

  it "renders the edit order_request form" do
    render

    assert_select "form[action=?][method=?]", order_request_path(@order_request), "post" do

      assert_select "input#order_request_client_account_id[name=?]", "order_request[client_account_id]"

      assert_select "input#order_request_date_bs[name=?]", "order_request[date_bs]"
    end
  end
end
