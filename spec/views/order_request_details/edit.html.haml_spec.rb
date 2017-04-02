require 'rails_helper'

RSpec.describe "order_request_details/edit", type: :view do
  before(:each) do
    @order_request_detail = assign(:order_request_detail, OrderRequestDetail.create!(
      :quantity => 1,
      :rate => 1,
      :status => 1,
      :isin_info => nil,
      :order_request => nil
    ))
  end

  it "renders the edit order_request_detail form" do
    render

    assert_select "form[action=?][method=?]", order_request_detail_path(@order_request_detail), "post" do

      assert_select "input#order_request_detail_quantity[name=?]", "order_request_detail[quantity]"

      assert_select "input#order_request_detail_rate[name=?]", "order_request_detail[rate]"

      assert_select "input#order_request_detail_status[name=?]", "order_request_detail[status]"

      assert_select "input#order_request_detail_isin_info_id[name=?]", "order_request_detail[isin_info_id]"

      assert_select "input#order_request_detail_order_request_id[name=?]", "order_request_detail[order_request_id]"
    end
  end
end
