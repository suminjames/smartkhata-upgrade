require 'rails_helper'

RSpec.describe "branches/new", type: :view do

  before(:each) do
    @branch = assign(:branch, Branch.new)
  end
  it "renders the new branch form" do
    render
    assert_select "form[action=?][method=?]", branches_path, "post" do

      assert_select "input#branch_code[name=?]", "branch[code]"

      assert_select "input#branch_address[name=?]", "branch[address]"

      assert_select "input#branch_top_nav_bar_color[name=?]", "branch[top_nav_bar_color]"

      assert_select  "p", :text => "Or select from the ones below"

      assert_select "div#recommendedColors"

      assert_select ".color-box", count:5

      assert_select "input[type=submit][value=?]" , "Create Branch"
    end

    assert_select "a[href=?]", branches_path


  end

end