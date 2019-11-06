require 'rails_helper'

RSpec.describe "branches/edit", type: :view do

  before(:each) do
    @branch = assign(:branch, Branch.create!(
        :code => "Danphe",
        :address => "kathmandu",
        :top_nav_bar_color => "#ffffff"
    ))
  end

  it "renders the edit branch form" do
    render

    assert_select "form[action=?][method=?]", branch_path(@branch), "post" do

      assert_select "input#branch_code[name=?]", "branch[code]"

      assert_select "input#branch_address[name=?]", "branch[address]"

      assert_select "input#branch_top_nav_bar_color[name=?]", "branch[top_nav_bar_color]"

      assert_select  "p", :text => "Or select from the ones below"

      assert_select "div#recommendedColors"

      assert_select ".color-box", count:5

      assert_select "input[type=submit][value=?]" , "Update Branch"

    end

    assert_select "a[href=?]", branch_path(@branch)

    assert_select "a[href=?]", branches_path


  end

end