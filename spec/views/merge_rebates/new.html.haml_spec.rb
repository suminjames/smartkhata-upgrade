require 'rails_helper'

RSpec.describe "merge_rebates/new", type: :view do
  before(:each) do
    assign(:merge_rebate, MergeRebate.new(
      :scrip => "MyString"
    ))
  end

  it "renders new merge_rebate form" do
    render

    assert_select "form[action=?][method=?]", merge_rebates_path, "post" do

      assert_select "input#merge_rebate_scrip[name=?]", "merge_rebate[scrip]"
    end
  end
end
