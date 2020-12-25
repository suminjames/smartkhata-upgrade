require 'rails_helper'

RSpec.describe "interest_particulars/show", type: :view do
  before(:each) do
    @interest_particular = assign(:interest_particular, InterestParticular.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
