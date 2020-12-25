require 'rails_helper'

RSpec.describe "interest_particulars/index", type: :view do
  before(:each) do
    assign(:interest_particulars, [
      InterestParticular.create!(),
      InterestParticular.create!()
    ])
  end

  it "renders a list of interest_particulars" do
    render
  end
end
