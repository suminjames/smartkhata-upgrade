require 'rails_helper'

RSpec.describe "merge_rebates/edit", type: :view do
  before(:each) do
    @merge_rebate = assign(:merge_rebate, MergeRebate.create!(
      :scrip => "MyString"
    ))
  end

  it "renders the edit merge_rebate form" do
    render

    assert_select "form[action=?][method=?]", merge_rebate_path(@merge_rebate), "post" do

      assert_select "input#merge_rebate_scrip[name=?]", "merge_rebate[scrip]"
    end
  end
end
