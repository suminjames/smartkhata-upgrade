require 'rails_helper'

RSpec.describe "interest_particulars/new", type: :view do
  before(:each) do
    assign(:interest_particular, InterestParticular.new())
  end

  it "renders new interest_particular form" do
    render

    assert_select "form[action=?][method=?]", interest_particulars_path, "post" do
    end
  end
end
