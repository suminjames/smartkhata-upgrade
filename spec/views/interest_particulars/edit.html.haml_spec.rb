require 'rails_helper'

RSpec.describe "interest_particulars/edit", type: :view do
  before(:each) do
    @interest_particular = assign(:interest_particular, InterestParticular.create!())
  end

  it "renders the edit interest_particular form" do
    render

    assert_select "form[action=?][method=?]", interest_particular_path(@interest_particular), "post" do
    end
  end
end
